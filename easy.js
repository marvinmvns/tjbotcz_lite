var fs = require("fs"); //filesystem
var opn = require('opn');
var express = require("express");
var bodyParser = require("body-parser");
const voices = {
              "es-ES": {"female" : "es-ES_LauraVoice", "male": "es-ES_EnriqueVoice"},
              "en-US": {"female" : "en-US_AllisonVoice", "male": "en-US_MichaelVoice"},
              "fr-FR": {"female" : "fr-FR_ReneeVoice"},
              "de-DE": {"female" : "de-DE_BirgitVoice", "male": "de-DE_DieterVoice"},
              }


//---------------------------------------------------------------------
// REST API
//---------------------------------------------------------------------


function initRestAPI() {
  var restAPI = express();
  restAPI.use(bodyParser.urlencoded({ extended: true }));
  restAPI.use(bodyParser.json());

  var port = 80;
  var router = express.Router();

  router.post('/cred', function(request, response){
    console.log(request.body);
    getCredentials(request.body);
    getConfig(request.body);
  });

  restAPI.use('/rest', router);
  restAPI.use(express.static(__dirname + '/public'));

  restAPI.listen(port);
  console.log('RestAPI is active on port ' + port);
  opn('http://localhost/index.html');
}

function getCredentials(message) {
  var stream = fs.createWriteStream(__dirname + '/configuration/credentials.js');
  stream.once('open', function(fd) {
    if (fd) {
      stream.write("/* \n * User-specific configuration \n * IMPORTANT NOTES: \n *   Please ensure you do not interchange your username and password. \n *   Your username is the longer value: 36 digits, including hyphens \n *   Your password is the smaller value: 12 characters \n */ \n ")
      stream.write(`\n exports.conversationWorkspaceId = '${message.wa_workspaceID}'; // replace with the workspace identifier of your conversation \n`);
      stream.write(`// Create the credentials object for export \n exports.credentials = {}; \n`);
      stream.write("\n //Watson Assistant \n // https://www.ibm.com/watson/ai-assistant/ \n" );
      stream.write(`exports.credentials.assistant = {iam_apikey: '${message.wa_iam_apikey}', url: '${message.wa_url}'}; \n`);
      stream.write("\n //Watson Speech to Text \n //For older instances use password/usrername fields instead of iam_apikey \n // https://www.ibm.com/watson/services/speech-to-text \n");
      stream.write(`exports.credentials.speech_to_text = {iam_apikey: '${message.stt_iam_apikey}', url: '${message.stt_url}'}; \n`);
      stream.write("\n //Watson Text to Speech \n //For older instances use password/usrername fields instead of iam_apikey \n // https://www.ibm.com/watson/services/text-to-speech \n");
      stream.write(`exports.credentials.text_to_speech = {iam_apikey: '${message.tts_iam_apikey}', url: '${message.tts_url}'}; \n`);
      stream.write("\n //Watson Visual Recognition \n // https://www.ibm.com/watson/services/visual-recognition \n");
      stream.write(`exports.credentials.visual_recognition = {iam_apikey: '${message.vr_iam_apikey}'}; \n`);
      if (message.ta_iam_apikey) {
        stream.write("\n //Watson Tone Analyzer \n // https://www.ibm.com/watson/services/tone-analyzer \n");
        stream.write(`exports.credentials.tone_analyzer = {iam_apikey: '${message.ta_iam_apikey}', url: '${message.ta_url}} \n`);
      } else {
        stream.write("\n /* \n //Watson Tone Analyzer \n // https://www.ibm.com/watson/services/tone-analyzer \n");
        stream.write(`exports.credentials.tone_analyzer = {iam_apikey: '', url: ''} \n */ \n`);
      }
      if (message.lt_iam_apikey) {
        stream.write("\n //Watson Language Translator \n // https://www.ibm.com/watson/services/language-translator \n");
        stream.write(`exports.credentials.language_translator = {iam_apikey: '${message.lt_iam_apikey}', \n url: '${message.lt_url}} \n`);
      } else {
        stream.write("\n /* \n //Watson Language Translator \n // https://www.ibm.com/watson/services/language-translator \n");
        stream.write(`exports.credentials.language_translator = {iam_apikey: '', url: ''} \n */ \n`);
      }
      stream.end();
      console.log("Credentials file was created.");
    } else {
      console.log("Something went wrong.");
    }
  });
}

function getConfig(message) {
  let voiceLanguage = voices[`${message.language_speak}`];
  let voice = voiceLanguage[`${message.gender}`];

  var configInfo = {
                    "tjname": message.tjname, 
                    "gender": message.gender,
                    "language_tts": message.language_speak,
                    "language_stt": message.language_hear, 
                    "voice": voice
                    };

  const newLocal = JSON.stringify(configInfo, null);
  var stream = fs.createWriteStream(__dirname + '/configuration/configInfo.js');
  stream.once('open', function(fd) {
    if (fd) {
      stream.write(`let configInfo = ${newLocal}; \n`);
      stream.write(`configInfo = JSON.stringify(configInfo, null); \n`);
      stream.write(`configInfo = JSON.parse(configInfo); \n`);
      stream.write(`exports.configInfo = configInfo; \n`);
      stream.end();
      console.log("Information for config file stored successfully.");
    } else {
      console.log("Something went wrong.");
    }
  });

}


//VISUAL RECOGNITION
//---------------------------------------------------------------------
initRestAPI();
