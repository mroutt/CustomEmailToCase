	
  public with sharing class ClaimInfoEmailHandler implements Messaging.InboundEmailHandler {
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        //TODO: Get the Claim Number out of the email subject

        //TODO: If there is no Claim Number found, reply to the sender to tell them that they need a Claim number

        //TODO: Look up the Claim Number custom field on the Case object

        //TODO: If a Case already exists for this Claim Number, link this email and all files to the Case
        
        //TODO: If a Case does not exist for this Claim Number, create a new Case

        //TODO: Reply with aa confirmation email to the sender 

        return result;
    }

    private void sendNoClaimNumberFoundEmail(String emailAddress) {

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        message.toAddresses = new String[] { emailAddress };
        message.subject = 'Opt Out Test Message';
        message.plainTextBody = 'This is the message body.';

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);    
    }

}
