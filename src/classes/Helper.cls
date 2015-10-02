public class Helper {
   	
	public static List<FieldsWraperJSON> getFieldsFromObject(String objectName) {
		
		Map<String, Schema.SobjectField> mainMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		List<FieldsWraperJSON> fieldsWraperList = new List<FieldsWraperJSON>();
		FieldsWraperJSON fieldsWrap;
		
		for(String fieldName : mainMap.keySet()) {
			Schema.SobjectField currentField = mainMap.get(fieldName);
			Schema.DescribeFieldResult describeField = currentField.getDescribe();
	        if(describeField.isUpdateable() && describeField.isAccessible()) { // && describeField.getReferenceTo().size() == 0
	        	
	        	String currentType = describeField.getType().name();
	        	
	        	if(fieldName != 'geolocation__latitude__s' && 
				   fieldName != 'geolocation__longitude__s' && 
				   currentType != 'BASE64' &&
				   currentType != 'DataCategoryGroupReference' &&
				   currentType != 'anytype') {
				   	
			   		fieldsWrap = new FieldsWraperJSON();
		            fieldsWrap.name = fieldName;
		            fieldsWrap.fieldType = describeField.getType().name();
		            if(fieldsWrap.fieldType == 'PICKLIST' || fieldsWrap.fieldType == 'MULTIPICKLIST') fieldsWrap.options =  getPicklistValues(describeField);
		            else fieldsWrap.options = new List<String>{'empty'};

                    fieldsWrap.isRequired = describeField.isCreateable() && !describeField.isNillable() && !describeField.isDefaultedOnCreate();
                    fieldsWrap.isCheked = fieldsWrap.isRequired;

		            fieldsWraperList.Add(fieldsWrap);
			   }
	        }
		}

		return fieldsWraperList;
	}
	
	public static List<String> getPicklistValues(Schema.DescribeFieldResult describeField) {
	
  		List<String> options = new List<String>();
   		List<Schema.PicklistEntry> ple = describeField.getPicklistValues();
        
   		for( Schema.PicklistEntry f : ple) {
   		   options.add(f.getValue() + '---' + f.getValue());
   		}       
   		return options;
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public static void checkTheUpdatedFields() {
		for(Data__c item : [SELECT Name FROM Data__c]) {
			Map<String, Schema.SobjectField> mainMap = Schema.getGlobalDescribe().get(item.Name).getDescribe().fields.getMap();
	        Data__c currentDataItem = [Select FieldList__c FROM Data__c WHERE Name =: item.Name LIMIT 1];
	    	String jsonFieldListFromDataObject = currentDataItem.FieldList__c; 

	        List<FieldsWraperJSON> fieldListFromDataObject = (List<FieldsWraperJSON>)JSON.deserialize(jsonFieldListFromDataObject, List<FieldsWraperJSON>.class);
	        List<FieldsWraperJSON> fieldListFromShema = TestGenController.getFieldsWraperListMain(TestGenController.getFieldsWraperListMain(getFieldsFromObject(item.Name)));

	         List<FieldsWraperJSON> listActiveFields = new List<FieldsWraperJSON>();

	        for(FieldsWraperJSON fieldForShema : fieldListFromShema) {
	            for(FieldsWraperJSON fieldFromDataObject : fieldListFromDataObject) {
	                if(fieldFromDataObject.name == fieldForShema.name) {
						listActiveFields.add(fieldFromDataObject);
						break;
	                }
	            }
	        }
	        currentDataItem.FieldList__c = JSON.serialize(listActiveFields);
	        update currentDataItem;
    	}
	}

	 public static void removeFromMainListOfDeletedObjects() { 
	 	List<Wraper> wraperList = new List<Wraper>();
	 	for(Data__c item : [SELECT Name, Count__c, Cheked__c, FieldList__c FROM Data__c]) 
			wraperList.add(new Wraper(item.Name, item.Count__c, item.Cheked__c, item.FieldList__c));

        List<String> items = new List<String>();
        for(Wraper wraper : wraperList) {
            if(Schema.getGlobalDescribe().get(wraper.name) == null) {
                items.add(wraper.name);
            }
        }     
        delete [SELECT Id FROM Data__c WHERE Name IN: items];
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static List<FieldsWraper> getFieldsWraperListMain(List<FieldsWraperJSON> jsonList) {
    	
    	List<FieldsWraper> mainList = new List<FieldsWraper>();
    	
    	for(FieldsWraperJSON item : jsonList) {
    		mainList.add(new FieldsWraper(item));
    	}
    	
    	return mainList;
    }

    public static List<FieldsWraperJSON> getFieldsWraperListMain(List<FieldsWraper> jsonList) {
    	
    	List<FieldsWraperJSON> mainList = new List<FieldsWraperJSON>();
    	
    	for(FieldsWraper item : jsonList) {
    		mainList.add(new FieldsWraperJSON(item));
    	}
    	
    	return mainList;
    }

    //public static List<FieldsWraper> getPagedFields(List<FieldsWraper> allFields, Integer currentPage) {
    //	List<FieldsWraper> pagedFields = new List<FieldsWraper>();
    //	for(Integer i = 1; i < allFields.size() + 1; i++) {
    //		if(i <= TestGenController.fieldsPageSize * currentPage && i > TestGenController.fieldsPageSize * currentPage - TestGenController.fieldsPageSize) {
    //			pagedFields.add(allFields[i - 1]);
    //		}
    //	}
    //	return pagedFields; 
    //}
}