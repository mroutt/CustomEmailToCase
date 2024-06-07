	
  public with sharing class ClaimInfoEmailHandler implements Messaging.InboundEmailHandler {
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        // String claimNumber = getClaimNumberFromSubject(email.subject);

        //TODO: If there is no Claim Number found, reply to the sender to tell them that they need a Claim number
        // if(claimNumber == null)
        //     return result;

        //Look up the Case by the Claim Number custom field
        //Case theCase = [SELECT Id FROM Case WHERE ClaimNumber__c = :claimNumber];

        //TODO: If a Case does not exist for this Claim Number, create a new Case
        //if(theCase == null)

        Case theCase = createNewCaseFromEmail(email);
        insert theCase;

        //TODO: If a Case already exists for this Claim Number, link this email and all files to the Case
        attachEmailToCase(email, theCase.Id);

        linkEmailAttachmentsToCase(email, theCase.Id);

        //TODO: Reply with a confirmation email to the sender 

        return result;
    }

    private static Case createNewCaseFromEmail(Messaging.InboundEmail email) {

        return new Case( Subject = email.subject, Status = 'New', Origin = 'Email' );
    }

    private static String getClaimNumberFromSubject(String subject) {

        // The claim number is always an 8 digit number
        Pattern thePattern = Pattern.compile('(\\d{8})');
        Matcher theMatcher = thePattern.matcher(subject);
        Boolean matches = theMatcher.find();

        if(matches)
            return theMatcher.group(1);

        return null;
    }

    private static void attachEmailToCase(Messaging.InboundEmail email, Id caseId) {


    }

    private static void linkEmailAttachmentsToCase(Messaging.InboundEmail email, Id caseId) {

        Messaging.InboundEmail.BinaryAttachment[] attachments = email.binaryAttachments;

        System.debug('This email has ' + attachments.size() + ' binary attachments.');
        for(Messaging.InboundEmail.BinaryAttachment attachment : attachments) {

            //TODO: Create Content Version for each email file attachment
            //TODO: Create Content Document Link to the provided CaseId, ContentDocumentLink.LinkedEntityId = CaseId

            ContentVersion content = new ContentVersion(
                                        Title = attachment.fileName,
                                        PathOnClient = attachment.fileName,
                                        VersionData = attachment.Body);

            insert content;

            ContentVersion contentWithDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id];

            ContentDocumentLink link = new ContentDocumentLink( ContentDocumentId = contentWithDocument.ContentDocumentId, LinkedEntityId = caseId );

            insert link;
        }

        
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
