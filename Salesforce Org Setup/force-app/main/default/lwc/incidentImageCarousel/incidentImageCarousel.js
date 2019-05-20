import {
  LightningElement,
  track,
  wire,
  api
} from 'lwc';
import {
  getRecord
} from 'lightning/uiRecordApi';
import getRelatedPictures from '@salesforce/apex/IncidentCtrl.findRelatedFiles';

export default class IncidentImageCarousel extends LightningElement {
  @api recordId;
  @track urls;
  pictures;

  @wire(getRecord, {
    recordId: '$recordId'
  })
  kase;

  @wire(getRelatedPictures, {
    caseId  : '$recordId',
    fileType: 'IMAGE'
  })
  wiredPictures(pictures) {
    this.pictures = pictures;
    if (pictures.data) {
      const files = pictures.data;
      if (Array.isArray(files) && files.length) {
        this.urls = files.map(
          file => '/sfc/servlet.shepherd/version/download/' + file.Id
        );
      } else {
        this.urls = null;
      }
    }
  }
}