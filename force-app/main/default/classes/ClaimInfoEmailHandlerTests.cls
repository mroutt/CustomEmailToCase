@isTest
private class ClaimInfoEmailHandlerTests {

    @isTest
    static void canLinkAttachmentToCase() {
        
        String subject = 'canLinkToCaseTest 88888888';
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = subject;
        email.binaryAttachments = createBinaryAttachments();

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

    private static Messaging.InboundEmail.BinaryAttachment[] createBinaryAttachments() {

        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();

        attachment.body = blob.valueOf('Some test text for the file');
        attachment.fileName = 'testAttachment.txt';
        attachment.mimeTypeSubType = 'text/plain';

        Messaging.inboundEmail.BinaryAttachment[] attachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        return attachments;
    }
}