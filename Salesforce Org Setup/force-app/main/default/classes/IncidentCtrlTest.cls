@isTest
private class IncidentCtrlTest {

    private static testmethod void Test1(){
        Case c = new Case(subject='test');
		insert c;
        
        ContentVersion contentVersionImage = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.PNG',
            FirstPublishLocationId=c.id,
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionImage;
        
        ContentVersion contentVersionAudio = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.M4A',
            FirstPublishLocationId=c.id,
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionAudio;
        
        IncidentCtrl.findRelatedFiles(c.id, 'AUDIO');
        IncidentCtrl.findRelatedFiles(c.id, 'IMAGE');
    }    
    
}