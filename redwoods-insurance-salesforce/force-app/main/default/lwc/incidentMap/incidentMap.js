import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const fields = [
    'Case.Incident_Location__Latitude__s',
    'Case.Incident_Location__Longitude__s'
];

export default class IncidentMap extends LightningElement {
    @api recordId;
    @track mapMarkers;
    @track error;
    @wire(getRecord, {
        recordId: '$recordId',
        fields
    })
    wiredMarker({ error, data }) {
        if (data) {
            this.mapMarkers = [
                {
                    location: {
                        Latitude:
                            data.fields.Incident_Location__Latitude__s.value,
                        Longitude:
                            data.fields.Incident_Location__Longitude__s.value
                    }
                }
            ];
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.mapMarkers = undefined;
        }
    }
}
