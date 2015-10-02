public with sharing class PicklistController {
	public String setupParam { get; set; }
	public String setupPicklistParam { get; set; }

	public List<OptionWraper> optionList { get; set; }	

	public PicklistController() {
		setupParam = apexpages.currentpage().getparameters().get('setupParam');
		setupPicklistParam = apexpages.currentpage().getparameters().get('setupPicklistParam');

		List<Schema.PicklistEntry> picklistEntryList = Schema.getGlobalDescribe().get(setupParam).getDescribe().fields.getMap().get(setupPicklistParam).getDescribe().getPicklistValues();
		optionList = new List<OptionWraper>();
        
        for(Schema.PicklistEntry picklistEntry : picklistEntryList)
        {
            optionList.add(new OptionWraper(picklistEntry.getLabel()));
        }  

        Data__c data = [SELECT FieldList__c FROM Data__c WHERE Name =:setupParam LIMIT 1];
		List<FieldsWraperJSON> activeFieldList = (List<FieldsWraperJSON>)JSON.deserialize(data.FieldList__c, List<FieldsWraperJSON>.class);
		for(FieldsWraperJSON field : activeFieldList) {
			if(field.optionWraperList != null && field.name == setupPicklistParam) {
				optionList = field.optionWraperList;
				break;
			}
		}
	}

	public void save() {
		Data__c data = [SELECT FieldList__c FROM Data__c WHERE Name =:setupParam LIMIT 1];
		List<FieldsWraperJSON> activeFieldList = (List<FieldsWraperJSON>)JSON.deserialize(data.FieldList__c, List<FieldsWraperJSON>.class);

		for(FieldsWraperJSON field : activeFieldList) {
			if(field.name == setupPicklistParam) {
				field.optionWraperList = optionList;
				break;
			}
		}
		data.FieldList__c = JSON.serialize(activeFieldList);
		update data;

	//	List<FieldsWraperJSON> fieldListFromDataObject = (List<FieldsWraperJSON>)JSON.deserialize(data.FieldList__c, List<FieldsWraperJSON>.class);
 //       List<FieldsWraperJSON> fieldListFromShema = getFieldsWraperListMain(getFieldsWraperListMain(Helper.getFieldsFromObject(setupParam)));

 //       for(FieldsWraperJSON fieldForShema : fieldListFromShema) {
 //           for(FieldsWraperJSON fieldFromDataObject : fieldListFromDataObject) {
 //               if(fieldFromDataObject.name == fieldForShema.name) {
 //                   fieldForShema.isCheked = fieldFromDataObject.isCheked;
 //                   fieldForShema.isRequired = fieldFromDataObject.isRequired;
 //                   fieldForShema.value = fieldFromDataObject.value;

 //                   if(fieldFromDataObject.optionWraperList != null) {
 //                      fieldForShema.optionWraperList = fieldFromDataObject.optionWraperList;
 //                   }                        
 //                   break;
 //               }
 //           }
 //       }

 //   	TestGenController.fieldsWraperListMainPaged = getFieldsWraperListMain(fieldListFromShema); 
 //   	TestGenController.fieldsWraperListMain = getPagedFields(fieldsWraperListMainPaged, 1);
	}
}