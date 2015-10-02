public class sObjectListPageController {
	
    public List<TestGenController.ObjectWraper> objectWraperlist {get; set;}
    public List<TestGenController.ObjectWraper> objectWraperlistPaged {get; set;}
    public String pager {get; set;}
    public String console {get; set;}
    String serializedList;
    
    Decimal pagesCount;
    Integer pageSize;
    Integer currentPage;
    
	public sObjectListPageController() {
		console = '';
		getObjectList();
		pageSize = 10;
		currentPage = 1;
		pager = '1/' + String.valueof(getLastPage());
		objectWraperlistPaged = getPagedFields(objectWraperlist, 1);
	}
	
    public List<TestGenController.ObjectWraper> getPagedFields(List<TestGenController.ObjectWraper> allFields, Integer currentPage) {
    	List<TestGenController.ObjectWraper> pagedFields = new List<TestGenController.ObjectWraper>();
    	for(Integer i = 1; i < allFields.size() + 1; i++) {
    		if(i <= pageSize*currentPage && i > pageSize*currentPage - pageSize) {
    			pagedFields.add(allFields[i - 1]);
    		}
    	}
    	return pagedFields; 
    }
    
    public void setFieldsPager(Integer currentField) {
    	pager = String.valueof(currentField) + '/' + String.valueof(getLastPage());
    }
	
    public Integer getLastPage() {
    	
    	Integer lastPage;
    	Integer mod = Math.mod(objectWraperlist.size(), pageSize);
    	
    	if(mod == 0) {
    		lastPage = objectWraperlist.size()/pageSize;
    	}
    	if(mod > 0) {
    		lastPage = objectWraperlist.size()/pageSize + 1;
    	}
    	
    	if (lastPage == 0) {
    		return 1;
    	}
    	
    	return lastPage;
    }
	
	public void getObjectList(){
		
		List<String> names = new List<String>();
		List<String> sortedList = new List<String>();
		objectWraperlist = new List<TestGenController.ObjectWraper>();
		
		for(Data__c item : [SELECT Name FROM Data__c]) names.add(item.name);
		
		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()) {
			String name = objTyp.getDescribe().getName();
        	if(!contains(name, names)) sortedList.add(name);
        }
        
        sortedList.sort();
        
        for(String objectName : sortedList) {
    		TestGenController.ObjectWraper obWrap = new TestGenController.ObjectWraper(objectName, false);
    		if(getFieldCountFromObject(objectName) != 0)
    			objectWraperlist.add(obWrap);
        }
    }
    
    public void AddObjectToData() {    	
    	
    	List<Data__c> items = new List<Data__c>();
    	
    	for(Integer i = 0; i < objectWraperlist.size(); i++) {
    		if(objectWraperlist[i].isCheked) {
    			items.add(new Data__c(Name = objectWraperlist[i].name, Cheked__c = false, Count__c = 10, FieldList__c = getSerializedList(objectWraperlist[i].name)));
    			objectWraperlist.Remove(i);
    			i--;
    		}
    	}
    	
    	insert items;
    	
    	if(currentPage == 1) first();
    	else {
	    	objectWraperlistPaged = getPagedFields(objectWraperlist, currentPage);
	       	setFieldsPager(currentPage);
	       	if(objectWraperlistPaged.size() == 0) {
	       		objectWraperlistPaged = getPagedFields(objectWraperlist, --currentPage);
	       		setFieldsPager(currentPage);
	       	}
    	}
    	
    }
    
    public String getSerializedList(String objectName) {
    	return new TestGenController(true).getSerializedList(objectName); 
    }
    
    public Boolean contains(String value, List<String> valuesList) {
    	
    	if(valuesList == NULL) return false;
    	
    	for(String item : valuesList) {
    		if(item == value) return true;
    	}
    	
    	return false;
    }
    
    public Integer getFieldCountFromObject(String objectName) {
			
		Integer i = 0;
		Map<String, Schema.SobjectField> mainMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		
		for(String fieldName : mainMap.keySet()) {
			Schema.DescribeFieldResult describeField = mainMap.get(fieldName).getDescribe();
	        if(describeField.isUpdateable() && describeField.isAccessible() && describeField.getReferenceTo().size() == 0) {
	        	i++;
	        }
		}
		 return i;
	}
	
	public void first() {
       objectWraperlistPaged = getPagedFields(objectWraperlist, 1);
       currentPage = 1;
       setFieldsPager(1);
   	}
    
    public void last() {
   		currentPage = getLastPage();
       	objectWraperlistPaged = getPagedFields(objectWraperlist, currentPage);
       	setFieldsPager(currentPage);
   	}
    
    public void next() {
    	List<TestGenController.ObjectWraper> currentFieldsList = getPagedFields(objectWraperlist, currentPage + 1);
    	if(currentFieldsList.size() != 0) {
	       	objectWraperlistPaged = currentFieldsList;
	       	setFieldsPager(++currentPage);
    	}
   	}
    
    public void previous() {
       	List<TestGenController.ObjectWraper> currentFieldsList = getPagedFields(objectWraperlist, currentPage - 1);
    	if(currentFieldsList.size() != 0) {
	       	objectWraperlistPaged = currentFieldsList;
	       	setFieldsPager(--currentPage);
    	}
    }
	
}