@RestResource(urlMapping='/api/WebHook/GitHub/push')
global with sharing class WebHookDemo {
    @HttpPost
    global static void handleNotification(){
        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            String hashedval = request.headers.get('X-Hub-Signature-256');
            System.debug('hashedval: ' + hashedval);
            Blob bBody = request.requestBody;
            System.debug(bBody.toString());

            Blob hmac = Crypto.generateMac('hmacSHA256', bBody, Blob.valueOf('webhook github'));
            
            String hmacString = 'sha256=' + EncodingUtil.convertToHex(hmac);
            System.debug(EncodingUtil.convertToHex(hmac));

            if (hashedval == hmacString) {
                System.debug('Deu certo');
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Success', 'Processed Successfully :)')));
            } else {
                response.statusCode = 401;
                response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Failure', 'Not a valid Sender :(')));
            }

        } catch (Exception e) {
            System.debug('Exception Happend: ' + e.getMessage());
        }
    }

    public class SFDCResponse{
        String response;
        String message;
        public SFDCResponse(String resp, String msg){
            response = resp;
            message = msg;
        }
    }
}
