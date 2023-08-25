trigger PreventLeadConvertNoOppTrigger on Lead (after update) {
    List<lead> leadList = new List<lead>();
    for(Lead record: Trigger.new) {
        if(record.IsConverted && !Trigger.oldMap.get(record.Id).IsConverted && record.ConvertedOpportunityId == null) {
            record.ConvertedOpportunityId.addError('You must provide an opportunity when converting leads.');
        }
    }
}