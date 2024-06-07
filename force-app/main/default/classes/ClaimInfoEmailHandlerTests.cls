@isTest
private class ClaimInfoEmailHandlerTests {

    @isTest
    static void canLinkAttachmentToCase() {
        
        String subject = 'canLinkToCaseTest';
        
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

    private static Messaging.InboundEmail.BinaryAttachment[] createBinaryAttachments() {

        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();

        attachment.body = blob.valueOf('Some test text for the file');
        attachment.fileName = 'testAttachment.txt';
        attachment.mimeTypeSubType = 'text/plain';

        Messaging.inboundEmail.BinaryAttachment[] attachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        return attachments;
    }
}