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
                System.debug('Secret value Matched and source can be trusted!');

                JSONParser parser = JSON.createParser(request.requestBody.toString());
                pusher ps;
                head_commit hc;
                String repo;
                System.debug('parser: ' + parser);
                while (parser.nextToken() != null) {
                    if (parser.getText() == 'pusher') {
                        System.debug('Inside pusher');
                        
                        parser.nextToken();
                        ps = (pusher)parser.readValueAs(pusher.class);
                        System.debug(ps);
                    }
                }

                GitHubPushDetails__c commitDetails = new GitHubPushDetails__c(
                    Name = ps!=null?ps.name:'',
                    Email__c = ps!=null?ps.email:''
                );
                insert commitDetails;

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
            this.response = resp;
            this.message = msg;
        }
    }

    public class pusher{
        public String name;
        public String email;
        public pusher(String name, String email){
            this.name = name;
            this.email = email;
        }
    }

    public class author{
        public String name;
        public String email;
        public author(String name, String email){
            name = name;
            email = email;
        } 
    }

    public class committer{
        public String name;
        public String email;
        public committer(String name, String email){
                name = name;
                email = email;
        } 
    }

    public class head_commit{
        public String id;
        public String tree_id;
        public String distinct;
        public String message;
        public String timestamp;
        public String url;
        public author autr;
        public committer comiter;
        public List<String> added;
        public List<String> removed;
        public List<String> modified;

        public head_commit(String id,String tree_id,String distinct,String message,String timestamp,String url,author autr,committer comiter,List<String> added,List<String> removed,List<String> modified){
            //set values
            id = id;
            tree_id = tree_id;
            distinct = distinct;
            message = message;
            timestamp = timestamp;
            url = url;
            autr    = autr;
            comiter = comiter;
            added = added;
            removed  = removed;
            modified = modified;
        }
    }
}