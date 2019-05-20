public with sharing class IncidentCtrl {
  
  @AuraEnabled(cacheable=true)
  public static List<ContentVersion> findRelatedFiles(Id caseId, String fileType){
    List<ContentDocumentLink> links;
    switch on fileType {
      when 'AUDIO' {
        links = [SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId=:caseId AND 
                  ContentDocument.FileType in ('M4A')];
      }
      when 'IMAGE' {
            links = [SELECT ContentDocumentId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId=:caseId AND
                      ContentDocument.title != 'MapSnapshot.png' AND
                      ContentDocument.FileType in ('PNG','JPG','GIF')];
      }
    }

    if(links.isEmpty()) {return null;}

    Set<Id> fileIds = new Set<Id>();
    for(ContentDocumentLink cdl: links){
      fileIds.add(cdl.ContentDocumentId);
    }
    return [SELECT Id, Title 
                FROM ContentVersion  
                WHERE ContentDocumentId IN :fileIds AND 
                  IsLatest=true 
                ORDER BY CreatedDate];

  }

}