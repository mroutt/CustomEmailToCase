@isTest
private class ClaimInfoEmailHandlerTests {

    @isTest
    static void canLinkAttachmentToCase() {
        
        String subject = 'canLinkToCaseTest 88888888';
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = subject;
        email.binaryAttachments = createBinaryAttachments(1);

        ClaimInfoEmailHandler handler = new ClaimInfoEmailHandler();

        handler.handleInboundEmail(email, envelope);

        List<Case> cases = [SELECT Id FROM Case];

        Assert.areEqual(1, cases.size());

        Case theCase = cases.get(0);

        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = : theCase.Id];

        Assert.areEqual(1, links.size());
    }

    @isTest
    static void canCreateCaseForClaimNumberInSubject() {

        String claimNumber = '99893345';
        String subject = 'Accident report for Claim number ' + claimNumber;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = subject;

        ClaimInfoEmailHandler handler = new ClaimInfoEmailHandler();

        handler.handleInboundEmail(email, envelope);

        List<Case> cases = [SELECT Id, ClaimNumber__c FROM Case];

        Assert.areEqual(1, cases.size());
        
        Case theCase = cases.get(0);

        Assert.areEqual(claimNumber, theCase.ClaimNumber__c);
    }

    @isTest
    static void noClaimNumberInSubjectReturnsFailure() {

        String errorMessage = 'Could not locate the 8-digit claim number in the email subject';
        String subject = 'No claim number subject';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = subject;

        ClaimInfoEmailHandler handler = new ClaimInfoEmailHandler();

        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);

        List<Case> cases = [SELECT Id, ClaimNumber__c FROM Case];

        Assert.areEqual(0, cases.size());
        Assert.isFalse(result.success);
        Assert.areEqual(errorMessage, result.message);
    }

    @isTest
    static void canLinkEmailToCase() {

        String claimNumber = '99893345';
        String subject = 'Accident report for Claim number ' + claimNumber;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = subject;

        ClaimInfoEmailHandler handler = new ClaimInfoEmailHandler();

        handler.handleInboundEmail(email, envelope);

        Case theCase = [SELECT Id FROM Case].get(0);

        List<EmailMessage> messages = [SELECT Id FROM EmailMessage WHERE ParentId = :theCase.Id];

        Assert.areEqual(1, messages.size());
    }

    @isTest 
    static void canHandleManyFileAttachments() {

        String subject = 'canLinkToCaseTest 88888888';
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = subject;
        email.binaryAttachments = createBinaryAttachments(100);

        ClaimInfoEmailHandler handler = new ClaimInfoEmailHandler();

        handler.handleInboundEmail(email, envelope);

        List<Case> cases = [SELECT Id FROM Case];

        Assert.areEqual(1, cases.size());

        Case theCase = cases.get(0);

        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = : theCase.Id];

        Assert.areEqual(100, links.size());
    }

    private static List<Messaging.InboundEmail.BinaryAttachment> createBinaryAttachments(Integer numberOfAttachments) {

        List<Messaging.InboundEmail.BinaryAttachment> attachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        for(Integer i = 0; i < numberOfAttachments; i++) {
            
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();

            attachment.body = blob.valueOf('Some test text for the file');
            attachment.fileName = 'testAttachment.txt';
            attachment.mimeTypeSubType = 'text/plain';
            
            attachments.add(attachment);
        }

        return attachments;
    }
}