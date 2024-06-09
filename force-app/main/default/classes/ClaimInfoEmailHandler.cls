	
  public with sharing class ClaimInfoEmailHandler implements Messaging.InboundEmailHandler {
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String claimNumber = getClaimNumberFromSubject(email.subject);

        //If there is no Claim Number found, reply to the sender and tell them that they need a Claim number
        if(claimNumber == null) {

            result.message = 'Could not locate the 8-digit claim number in the email subject';
            result.success = false;
            return result;
        }

        //Look up the Case by the Claim Number custom field
        List<Case> cases = [SELECT Id FROM Case WHERE ClaimNumber__c = :claimNumber];

        Case theCase;

        //If a Case does not exist for this Claim Number, create a new Case
        if(cases.size() == 0) {

            theCase = createNewCaseFromEmail(email, claimNumber);
            insert theCase;    

        } else {

            theCase = cases.get(0);
        }

        attachEmailToCase(email, theCase.Id);

        linkEmailAttachmentsToCase(email, theCase.Id);

        result.success = true;
        return result;
    }

    private static Case createNewCaseFromEmail(Messaging.InboundEmail email, String claimNumber) {

        return new Case( Subject = email.subject, Status = 'New', Origin = 'Email', ClaimNumber__c = claimNumber );
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

        EmailMessage message = new EmailMessage();
        message.ParentId = caseId;
        message.FromAddress = email.fromAddress;
        message.HtmlBody = email.htmlBody;
        message.Subject = email.subject;

        insert message;
    }

    private static void linkEmailAttachmentsToCase(Messaging.InboundEmail email, Id caseId) {

        if(email.binaryAttachments == null)
            return;

        // TODO: Add support for text attachments
        Messaging.InboundEmail.BinaryAttachment[] attachments = email.binaryAttachments;

        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for(Messaging.InboundEmail.BinaryAttachment attachment : attachments) {

            ContentVersion content = new ContentVersion(
                                        Title = attachment.fileName,
                                        PathOnClient = attachment.fileName,
                                        VersionData = attachment.Body);

            contentVersions.add(content);
        }

        insert contentVersions;

        // Here we pass our newly created Content Version list to the Map constructor.
        // This allows us to extract the new ids into a Set.
        // We can then use that Set of Ids in a SOQL WHERE IN clause to get the list of ContentDocument records that 
        // we need to link to the Case
        Map<Id, ContentVersion> contentVersionMap = new Map<Id,ContentVersion>(contentVersions);
        Set<Id> newContentVersionIds = contentVersionMap.keySet();

        List<ContentVersion> contentVersionsWithDocumentIds = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :newContentVersionIds];

        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();

        for(ContentVersion contentVersionWithDocumentId : contentVersionsWithDocumentIds) {

            ContentDocumentLink link = new ContentDocumentLink( ContentDocumentId = contentVersionWithDocumentId.ContentDocumentId, LinkedEntityId = caseId );
            documentLinks.add(link);
        }
        
        insert documentLinks;
        
    }
}
