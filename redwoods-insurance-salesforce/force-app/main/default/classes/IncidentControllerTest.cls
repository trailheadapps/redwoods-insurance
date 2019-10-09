@isTest
private class IncidentControllerTest {
    @isTest
    private static void findRelatedFilesPositive() {
        Case c = new Case(subject = 'test');
        insert c;

        ContentVersion contentVersionImage = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.PNG',
            FirstPublishLocationId = c.id,
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionImage;

        ContentVersion contentVersionAudio = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.M4A',
            FirstPublishLocationId = c.id,
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionAudio;

        List<ContentVersion> audio = IncidentController.findRelatedFiles(
            c.id,
            'AUDIO'
        );
        List<ContentVersion> images = IncidentController.findRelatedFiles(
            c.id,
            'IMAGE'
        );
        System.assertNotEquals(
            0,
            audio.size(),
            'expected to find at least one audio file'
        );
        System.assertNotEquals(
            0,
            images.size(),
            'expected to find at least one audio file'
        );
    }
}
