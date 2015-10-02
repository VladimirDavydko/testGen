public class sObjectListController {
	
    public List<ObjectWraper> objectWraperlist {get; set;}
    List<Data__c> dataItems;
    
    public sObjectListController() {
    	getObjectList();
    }
    public class ObjectWraper {
    	
    	public String name {get;set;}
    	public Boolean isCheked {get;set;}
    	public ObjectWraper(String name, Boolean isChecked) {
    		this.name = name;
    		this.isCheked = isChecked;
    	}
    }
    
    public class Helper {
    	
    	public List<FieldsWraperJSON> getFieldsFromObject(String objectName) {
			
			Map<String, Schema.SobjectField> mainMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
			List<FieldsWraperJSON> fieldsWraperList = new List<FieldsWraperJSON>();
			FieldsWraperJSON fieldsWrap;
			
			for(String fieldName : mainMap.keySet()) {
				Schema.SobjectField currentField = mainMap.get(fieldName);
				Schema.DescribeFieldResult describeField = currentField.getDescribe();
		        if(describeField.isUpdateable() && describeField.isAccessible() && describeField.getReferenceTo().size() == 0) {
		        	fieldsWrap = new FieldsWraperJSON();
		            fieldsWrap.name = fieldName;
		            fieldsWrap.fieldType = describeField.getType().name();
		            if(fieldsWrap.fieldType == 'PICKLIST') fieldsWrap.options = getPicklistValues(describeField);
		            else fieldsWrap.options = new List<String>{'empty'};
		            fieldsWraperList.Add(fieldsWrap);
		        }
			}
			 return fieldsWraperList;
		}
		
		public List<String> getPicklistValues(Schema.DescribeFieldResult describeField) {
		
	  		List<String> options = new List<String>();
	   		List<Schema.PicklistEntry> ple = describeField.getPicklistValues();
	        
	   		for( Schema.PicklistEntry f : ple) {
	   		   options.add(f.getValue() + '---' + f.getValue());
	   		}       
	   		return options;
		}
    }
    
    public void getObjectList(){
		
		objectWraperlist = new List<ObjectWraper>();
		dataItems = [SELECT Id, Name, Cheked__c FROM Data__c];
		
    	List<String> stringValues = new List<String>();
    	
    	for(Data__c item : DataItems) {
    		stringValues.add(item.name);
    	}
    	
    	List<String> sortedList = new List<String>();
		
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
        	sortedList.add(objTyp.getDescribe().getName());
        }
        
        sortedList.sort();
        
        for(String objectName : sortedList) {
        	if(!contains(objectName, stringValues)) {
        		ObjectWraper obWrap = new ObjectWraper(objectName, false);
        		if(new Helper().getFieldsFromObject(obWrap.name).size() != 0)
        			objectWraperlist.add(obWrap);
        	}
        }
    }
    
    public Boolean contains(String value, List<String> valuesList) {
	
		if(valuesList == NULL) return false;
		
		for(String item : valuesList) {
			if(item == value) return true;
		}
		
		return false;
	}
}