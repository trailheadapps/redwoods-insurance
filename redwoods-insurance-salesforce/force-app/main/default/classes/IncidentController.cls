/**
 * @File Name          : IncidentController.cls
 * @Description        :
 * @Author             : Kevin Poorman  - Kpoorman@salesforce.com - @Codefriar
 * @Group              :
 * @Last Modified By   : Kevin Poorman  - Kpoorman@salesforce.com - @Codefriar
 * @Last Modified On   : 2/14/2020, 9:45:26 AM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2/14/2020   Kevin Poorman  - Kpoorman@salesforce.com - @Codefriar     Initial Version
 **/
public with sharing class IncidentController {
    /**
     * @description - returns a list of files (content versions) associated with the case ID and limited to the fileType
     * @author Kevin Poorman  - Kpoorman@salesforce.com - @Codefriar | 2/14/2020
     * @param caseId - ID of related case
     * @param fileType - [AUDIO, IMAGE]
     * @return List<ContentVersion> (files)
     **/
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> findRelatedFiles(
        Id caseId,
        String fileType
    ) {
        List<ContentDocumentLink> links;
        switch on fileType {
            when 'AUDIO' {
                links = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE
                        LinkedEntityId = :caseId
                        AND ContentDocument.FileType IN ('M4A')
                    WITH SECURITY_ENFORCED
                ];
            }
            when 'IMAGE' {
                links = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE
                        LinkedEntityId = :caseId
                        AND ContentDocument.title != 'MapSnapshot.png'
                        AND ContentDocument.FileType IN ('PNG', 'JPG', 'GIF')
                    WITH SECURITY_ENFORCED
                ];
            }
        }

        if (links.isEmpty()) {
            return null;
        }

        Set<Id> fileIds = new Set<Id>();
        for (ContentDocumentLink cdl : links) {
            fileIds.add(cdl.ContentDocumentId);
        }
        return [
            SELECT Id, Title
            FROM ContentVersion
            WHERE ContentDocumentId IN :fileIds AND IsLatest = true
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate
        ];
    }
}
