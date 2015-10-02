public class TestGenController {

    public Wraper wraper { get; set; }
    public FieldsWraperJSON fieldsWraper { get; set; }
    public FieldsWraper fieldsWraperMain { get; set; }    
    
    public List<FieldsWraperJSON> fieldsWraperList { get; set; }
    public List<FieldsWraper> fieldsWraperListMain { get; set; }
    public List<FieldsWraper> fieldsWraperListMainPaged { get; set; }
    public List<Wraper> wraperList { get; set; }
    public List<ObjectWraper> objectWraperlist { get; set; } 
    public List<SelectOption> selectOptionList { get; set; } 

    public Map<String, Schema.SObjectType> globalDescribe { get; set; }
    
    public String setupParam { get; set; }
    public String setupPicklistParam { get; set; }
    public Boolean renderFields { get; set; }
    public Boolean renderMainObjects { get; set; }
    public static String console { get; set; }
    public String pager { get; set; }
    public String fieldsPager { get; set; }
    
    public Boolean needToShowObjectsPaging { get; set; }
    public Boolean needToShowFieldsPaging { get; set; }
    
    Decimal pagesCount;
    Integer pageSize;
    Map<String, String> fieldValueMap;
    Boolean chekedUncheked;
    List<sObject> allObjects;
    List<Data__c> dataItems;
    Integer fieldsPageSize;
    Integer currentFieldPage;
    
    public ApexPages.StandardSetController paginator { get; set; }
    
    public TestGenController() {
        globalDescribe = Schema.getGlobalDescribe();

    	console = '';
    	needToShowObjectsPaging = true;
    	renderFields = false;
    	pageSize = 10;
    	fieldsPageSize = 20;
    	currentFieldPage = 1;
    	initializePaginator();
    	chekedUncheked = true;
        open();
        checkMainObjectsVisibility();
    }
    
    public TestGenController(Boolean isEmptyConstructor) {
    	//do not remove
    }
    
    public void initializePaginator() {
    	
    	Integer pageNumber = 1;
    	Boolean isLastPage = false;
    	
    	if(paginator != NULL) {
    		pageNumber = paginator.getpageNumber();
    		if(!paginator.getHasNext()) isLastPage = true;
    	}
    	
    	dataItems = [SELECT Name, Cheked__c, FieldList__c, Count__c FROM Data__c ORDER BY CreatedDate];
    	setPagesCount();
    	paginator = new ApexPages.StandardSetController(dataItems);
    	paginator.setPageSize(pageSize);
    	if(!isLastPage) paginator.setpageNumber(pageNumber);
    	else last();
    }
    
    public void setPagesCount() {
    	
    	Integer mod = Math.mod(dataItems.size(), pageSize);
    	
    	if(mod == 0) {
    		pagesCount = dataItems.size() / pageSize;
    	}
    	if(mod > 0) {
    		pagesCount = dataItems.size() / pageSize + 1;
    	}    	
    	if(pagesCount == 0 || pagesCount == 1) needToShowObjectsPaging = false;
    	else needToShowObjectsPaging = true;
    }
        
    public List<FieldsWraper> getPagedFields(List<FieldsWraper> allFields, Integer currentPage) {
    	List<FieldsWraper> pagedFields = new List<FieldsWraper>();
    	for(Integer i = 1; i < allFields.size() + 1; i++) {
    		if(i <= fieldsPageSize * currentPage && i > fieldsPageSize * currentPage - fieldsPageSize) {
    			pagedFields.add(allFields[i - 1]);
    		}
    	}
    	return pagedFields; 
    }
    
    public void Setup() { 
    	try {
    		Map<String, Schema.SobjectField> mainMap = globalDescribe.get(setupParam).getDescribe().fields.getMap();
            Data__c currentDataItem = [Select FieldList__c FROM Data__c WHERE Name =: setupParam LIMIT 1];
	    	String jsonActiveFieldList = currentDataItem.FieldList__c; 

            List<FieldsWraperJSON> fieldListFromDataObject = (List<FieldsWraperJSON>)JSON.deserialize(jsonActiveFieldList, List<FieldsWraperJSON>.class);
            List<FieldsWraperJSON> fieldListFromShema = Helper.getFieldsWraperListMain(Helper.getFieldsWraperListMain(Helper.getFieldsFromObject(setupParam)));

            for(FieldsWraperJSON fieldForShema : fieldListFromShema) {
                for(FieldsWraperJSON fieldFromDataObject : fieldListFromDataObject) {
                    if(fieldFromDataObject.name == fieldForShema.name) {
                        fieldForShema.isCheked = fieldFromDataObject.isCheked;
                        fieldForShema.isRequired = fieldFromDataObject.isRequired;
                        fieldForShema.value = fieldFromDataObject.value;

                        if(fieldFromDataObject.optionWraperList != null) {
                           fieldForShema.optionWraperList = fieldFromDataObject.optionWraperList;
                        }                        
                        break;
                    }
                }
            }

	    	fieldsWraperListMainPaged = Helper.getFieldsWraperListMain(fieldListFromShema);
	    	fieldsWraperListMain = getPagedFields(fieldsWraperListMainPaged, 1);
    	}
    	catch(Exception e) {
            console = e.getMessage()  + ' : ' + e.getStackTraceString();
    		fieldsWraperListMain = getPagedFields(Helper.getFieldsWraperListMain(Helper.getFieldsFromObject(setupParam)), 1);
     	}
    	
    	setFieldsPager(1);
    	renderFields = true;
    }
    
    public Integer getLastPage() {
    	
    	Integer lastPage;
    	
    	Integer mod = Math.mod(fieldsWraperListMainPaged.size(), fieldsPageSize);
    	
    	if(mod == 0) {
    		lastPage = fieldsWraperListMainPaged.size() / fieldsPageSize;
    	}
    	if(mod > 0) {
    		lastPage = fieldsWraperListMainPaged.size() / fieldsPageSize + 1;
    	}

    	if(lastPage == 0) {
    		needToShowFieldsPaging = false;
    		return 1;
    	}    	
    	if(lastPage == 1) needToShowFieldsPaging = false;
    	else needToShowFieldsPaging = true;
    	
    	return lastPage;
    }
    
    public void setFieldsPager(Integer currentField) {
    	fieldsPager = String.valueof(currentField) + '/' + String.valueof(getLastPage());
    }
        
	public void firstField() {
       fieldsWraperListMain = getPagedFields(fieldsWraperListMainPaged, 1);
       currentFieldPage = 1;
       setFieldsPager(1);
   	}
    
    public void lastField() {
   		currentFieldPage = getLastPage();
       	fieldsWraperListMain = getPagedFields(fieldsWraperListMainPaged, currentFieldPage);
       	setFieldsPager(currentFieldPage);
   	}
    
    public void nextField() {
    	List<FieldsWraper> currentFieldsList = getPagedFields(fieldsWraperListMainPaged, currentFieldPage + 1);
    	if(currentFieldsList.size() != 0) {
	       	fieldsWraperListMain = currentFieldsList;
	       	setFieldsPager(++currentFieldPage);
    	}
   	}
    
    public void previousField() {
       	List<FieldsWraper> currentFieldsList = getPagedFields(fieldsWraperListMainPaged, currentFieldPage - 1);
    	if(currentFieldsList.size() != 0) {
	       	fieldsWraperListMain = currentFieldsList;
	       	setFieldsPager(--currentFieldPage);
    	}
    }
    
    public class ObjectWraper {    	
    	public String name {get;set;}
    	public Boolean isCheked {get;set;}
    	public ObjectWraper(String name, Boolean isChecked) {
    		this.name = name;
    		this.isCheked = isChecked;
    	}
    }
    
    public class Wraper {    	
        public String name {get; set;}
        public Boolean isCheked {get;set;}
        public Boolean isNeedToDelete {get;set;}
        public Decimal objectCount {get;set;}
        public List<FieldsWraperJSON> fieldsWraperList {get; set;}
        
        public Wraper(String objectName) {
        	name = objectName;
        	fieldsWraperList = Helper.getFieldsFromObject(objectName);
        	isNeedToDelete = false;
        }
        
        public Wraper(String objectName, Decimal objectCount, Boolean cheked, String jsonFields) {
        	name = objectName;
        	this.objectCount = objectCount;
        	isCheked = cheked;
        	fieldsWraperList = (List<FieldsWraperJSON>)JSON.deserialize(jsonFields, List<FieldsWraperJSON>.class);
        	isNeedToDelete = false;
        }
    }

    public void refresh() {
    	renderFields = false;
    	setupParam = '';
    	initializePaginator();
    	open();
        checkMainObjectsVisibility();
    }
    
    public void selectAll() {
    	for(Wraper wraper : wraperList) {
    		wraper.isNeedToDelete = chekedUncheked;
    	}    	
    	chekedUncheked = !chekedUncheked;
    }
    
    public String getSerializedList(String objectName) {
    	return JSON.serialize(Helper.getFieldsWraperListMain(Helper.getFieldsWraperListMain(Helper.getFieldsFromObject(objectName))));
    }
    
    public static List<FieldsWraper> getFieldsWraperListMain(List<FieldsWraperJSON> jsonList) {
    	
    	List<FieldsWraper> mainList = new List<FieldsWraper>();
    	
    	for(FieldsWraperJSON item : jsonList) {
    		mainList.add(new FieldsWraper(item));
    	}
    	
    	return mainList;
    }
    
    public static List<FieldsWraperJSON>  getFieldsWraperListMain(List<FieldsWraper> jsonList) {
    	
    	List<FieldsWraperJSON> mainList = new List<FieldsWraperJSON>();
    	
    	for(FieldsWraper item : jsonList) {
    		mainList.add(new FieldsWraperJSON(item));
    	}
    	
    	return mainList;
    }
    
    public void open() {
    	
    	wraperList = new List<Wraper>();
		dataItems = (List<Data__c>)paginator.getRecords();
		
		for(Data__c item : dataItems) 
			wraperList.add(new Wraper(item.Name, item.Count__c, item.Cheked__c, item.FieldList__c));
			
		renderFields = false;
    	pager = String.valueof(paginator.getPageNumber()) + '/' + String.valueof(pagesCount);
    }
    
    public void Save() {
		for(Data__c item : dataItems) {
    		for(Wraper wraper : wraperList) {
    			if(wraper.objectCount > 1000) wraper.objectCount = 1000;
    			if(wraper.Name == setupParam && item.Name == setupParam) {
			    	item.Cheked__c = wraper.isCheked;
			    	item.Count__c = wraper.objectCount >= 0 &&  wraper.objectCount <= 1000 ? wraper.objectCount : 10;

                    List<FieldsWraper> listActiveFields = new List<FieldsWraper>();
                    for(Integer i = 0; i < fieldsWraperListMainPaged.size(); i++) {
                       if(fieldsWraperListMainPaged[i].isCheked == true) {
                          listActiveFields.add(fieldsWraperListMainPaged[i]);
                       }
                    }

			    	for(FieldsWraper mainWraper : fieldsWraperListMainPaged) {
			    		for(FieldsWraper currentWraper : fieldsWraperListMain) {
			    			if(mainWraper.name == currentWraper.name) mainWraper = currentWraper;
			    		}
			    	}
			    	item.FieldList__c = JSON.serialize(Helper.getFieldsWraperListMain(listActiveFields));
		    	}
		    	else if(wraper.Name == item.Name) {
			    	item.Cheked__c = wraper.isCheked;
			    	item.Count__c = wraper.objectCount;
		    	}
    		}
    	}
    	
    	upsert dataItems;
    	initializePaginator();
    }
    
    public void deleteObjectFromMainList() {
    	List<String> items = new List<String>();
    	for(Wraper wraper : wraperList) {
    		if(wraper.isNeedToDelete) items.add(wraper.name);
    	}
    	
    	delete [SELECT Id FROM Data__c WHERE Name IN: items];
    	renderFields = false;
    	setupParam = '';
    	initializePaginator();
    	open();
    	checkMainObjectsVisibility();
    }
	
	public void getObjectList() {
		
		objectWraperlist = new List<ObjectWraper>();
		
    	List<String> stringValues = new List<String>();
    	
    	for(Data__c item : dataItems) {
    		stringValues.add(item.name);
    	}
    	
    	List<String> sortedList = new List<String>();
		
        for(Schema.SObjectType objTyp : globalDescribe.Values()){
        	sortedList.add(objTyp.getDescribe().getName());
        }
        
        sortedList.sort();
        
        for(String objectName : sortedList) {
        	if(!contains(objectName, stringValues) && objectName != 'Data__c') {
        		ObjectWraper obWrap = new ObjectWraper(objectName, false);
        		if(Helper.getFieldsFromObject(obWrap.name).size() != 0)
        			objectWraperlist.add(obWrap);
        	}
        }
    }
    
    public void AddObjectToData() {    	    	
       	open();
    	checkMainObjectsVisibility();
    }
    
    public Boolean contains(String value, List<String> valuesList) {
    	
    	if(valuesList == NULL) return false;
    	
    	for(String item : valuesList) {
    		if(item == value) return true;
    	}
    	
    	return false;
    }
    
    public void checkMainObjectsVisibility() {
        if(wraperList.size() > 0) renderMainObjects = true;
        else renderMainObjects = false;
    }
	
	public void hideFields() {
		renderFields = false;
	}
	
	public void run() {
		system.debug('*** Start RUN ***');
		allObjects = new List<sObject>();
		Map<String, Map<String, String[]>> activeObjectNamesAndFields = new Map<String, Map<String, String[]>>();
		List<Data__c> records = [SELECT FieldList__c, Name, Cheked__c, Count__c FROM Data__c WHERE Cheked__c = true];
		Map<String, List<SelectOption>> picklistMap = new Map<String, List<SelectOption>>();
		Map<String, String> multiPicklistMap = new Map<String, String>();
		Map<String, List<String>> references = new Map<String, List<String>>();
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        Integer totalCount = 0;

        for(Data__c record : records) {
            totalCount += Integer.valueOf(record.Count__c);
        }

        List<Map<String, String>> usersInfo = getUsersInfo(totalCount);
	
        for(Integer j = 0; j < records.size(); j++) {

			system.debug('*** record = ' + records[j].Name);
			Map<String, String[]> nameValueTypeMap = new Map<String, String[]>();
			List<FieldsWraper> fieldsWrapers = Helper.getFieldsWraperListMain((List<FieldsWraperJSON>)JSON.deserialize(records[j].FieldList__c, List<FieldsWraperJSON>.class));
			for(FieldsWraper fieldWraper : fieldsWrapers) {
				if(fieldWraper.isCheked == true) {
					system.debug('*** Field = ' + fieldWraper.Name);
					if(fieldWraper.options.size() == 0) {
						nameValueTypeMap.put(fieldWraper.name, new String[]{fieldWraper.value, fieldWraper.fieldType});
					}
					else {
						if(fieldWraper.fieldType == 'PICKLIST')
							picklistMap.put(fieldWraper.name, fieldWraper.options);
						if(fieldWraper.fieldType == 'MULTIPICKLIST'){}
							//multiPicklistMap.put(fieldWraper.name, fieldWraper.options);
					}
				}
			}
			
			if(nameValueTypeMap.size() == 0 && picklistMap.size() == 0 && multiPicklistMap.size() == 0) continue;
			
			for(String key : nameValueTypeMap.keySet()) {
				String value = nameValueTypeMap.get(key)[0];
				String fieldType = nameValueTypeMap.get(key)[1];
				
				if(fieldType == 'REFERENCE') {
					List<id> referencesList = new List<Id>();
					List <Schema.sObjectType> ref = globalDescribe.get(records[j].Name).getDescribe().fields.getMap().get(key).getDescribe().getReferenceTo();
					//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    if(ref.size() == 1) {
						String objName = String.valueof(ref[0].getDescribe().getName());
						List<SObject> objects = database.query('SELECT Id FROM ' + objName + ' LIMIT 100');
						for(SObject obj : objects) {
							referencesList.add(obj.Id);
						}
					}
					references.put(key, referencesList);
				}
			}
			
			activeObjectNamesAndFields.put(records[j].Name, nameValueTypeMap);
			SObjectType currentType = globalDescribe.get(records[j].Name).getDescribe().getSobjectType();	        		
			
			for(Integer i = 0; i < records[j].Count__c; i++) {

                totalCount--;

				SObject currentObject = currentType.newSObject();
				
                for(String key : picklistMap.keySet()) {
                    List<SelectOption> selectOptions = picklistMap.get(key);
                    Integer rand = Integer.valueof(selectOptions.size() * Math.random());

                    currentObject.put(key, selectOptions[rand].getValue());
                }
				
				for(String key : multiPicklistMap.keySet()) {
					List<SelectOption> selectOptions = picklistMap.get(key);
					Integer rand = Integer.valueof(selectOptions.size() * Math.random());
					currentObject.put(key, selectOptions[rand].getValue());
				}
                picklistMap.clear();

				for(String key : nameValueTypeMap.keySet()) {
					String value = nameValueTypeMap.get(key)[0];
					String fieldType = nameValueTypeMap.get(key)[1];
					
					if(fieldType == 'REFERENCE') {
						List<String> currentReferences = references.get(key);
						if(currentReferences != NULL && currentReferences.size() != 0)
							currentObject.put(key, currentReferences[Integer.valueof((currentReferences.size() - 1) * Math.random())]);
					}					
					else if(fieldType == 'Double' || fieldType == 'Currency' || fieldType == 'Percent') {

						if (fieldType == 'Percent') {
							currentObject.put(key, Decimal.valueof(100 * Math.random()));
						}
                        Double randomPositiveOrNegativeValue = Math.random() - Math.random();
                        if(key == 'billinglatitude') {
                            currentObject.put(key, Double.valueof(randomPositiveOrNegativeValue * 90));
                        }
                        else if(key == 'billinglongitude') {
                           currentObject.put(key, Double.valueof(randomPositiveOrNegativeValue * 180));
                        }
						else currentObject.put(key, Decimal.valueof(value + i * 1000*Math.random()));
					}					
					else if(fieldType == 'Email') {
						Pattern p = Pattern.compile('([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');
					    Matcher m = p.matcher(value);
					    
					    if (m.matches()) {
					    	currentObject.put(key, value);
					    }
					    else if (value == '' && p.matcher(usersInfo[i].get(key)).matches()) {
                            currentObject.put(key, usersInfo[i].get(key));
                        }
                        else {
                             currentObject.put(key, constructTestString(10) + '@gmail.com');
                        }
					}					
					else if(fieldType == 'Integer') {
					   currentObject.put(key, Integer.valueof(i * 1000 * Math.random()));
	
					}					
					else if(fieldType == 'DATE') {
						try {
							String[] dateParts = value.split('-', -3);
							if(dateParts.size() == 3) {
								Date currentDate = Date.newInstance(integer.valueof(dateParts[2]), integer.valueof(dateParts[1]), integer.valueof(dateParts[0]));
								currentObject.put(key, currentDate);
							}
							else {
								Integer year = (date.today().year() - 10) + Integer.valueof(Math.random() * 15);
								Date currentDate = date.newinstance(year, Integer.valueof(12 * Math.random()), Integer.valueof(28 * Math.random()));
								currentObject.put(key, currentDate);
							}
						}
						catch(Exception e) {
							console = e.getMessage();
						}
					}				
					else if(fieldType == 'BOOLEAN') {
						if(value =='Random')
							currentObject.put(key, Math.random() < 0.5);
						else currentObject.put(key, Boolean.valueof(value));
					}			
					else if(fieldType == 'Time') {
						Time myTime = Time.newInstance(Integer.valueof(24 * Math.random()), Integer.valueof(60 * Math.random()), Integer.valueof(60 * Math.random()), Integer.valueof(1000 * Math.random()));
						currentObject.put(key, myTime);
					}					
					else if(fieldType == 'DateTime') {
						Time myTime = Time.newInstance(Integer.valueof(24 * Math.random()), Integer.valueof(60 * Math.random()), Integer.valueof(60 * Math.random()), Integer.valueof(1000 * Math.random()));
						Date myDate = date.newinstance((date.today().year() - 10) + Integer.valueof(Math.random() * 15), Integer.valueof(12 * Math.random()), Integer.valueof(28 * Math.random()));
						currentObject.put(key, DateTime.newInstance(myDate, myTime));
					}					
					else if(fieldType == 'PICKLIST' || fieldType == 'MULTIPICKLIST') {
						//continue;
					}					
					else if(value != null && value != '') {
                        currentObject.put(key, value);
                    }
                    else {
                        if(key == 'name') {
                            currentObject.put(key, usersInfo[totalCount].get('username'));
                        }
                        else if(key == 'firstname' || key == 'lastname' || key == 'phone') {
                           currentObject.put(key, usersInfo[j].get(key));
                        }
                        else if(key.contains('street')) {
                            currentObject.put(key, usersInfo[j].get('street'));
                        }
                        else if(key.contains('city')) { 
                            currentObject.put(key, usersInfo[j].get('city'));
                        }
                        else if(key.contains('state')) { 
                            currentObject.put(key, usersInfo[j].get('state'));
                        }
                        else if(key.contains('country')) { 
                            currentObject.put(key, usersInfo[j].get('country'));
                        }
                        else if(key.contains('postalcode')) { 
                            currentObject.put(key, usersInfo[j].get('postalcode'));
                        }
                        else currentObject.put(key, constructTestString(10));
                    }
				}		
				allObjects.add(currentObject);
			}			
		}
		try {
			insert allObjects;
		}
		catch(Exception e) { 
            console += e.getMessage() + ' ' + e.getStackTraceString();
        }
	}
	
	public void deleteNearestCreatedObjects() {
		try {
			delete allObjects;
		}
		catch(Exception e) {
			
		}
	}    
	
	public void first() {
       paginator.first();
       open();
   	}
    
    public void last() {
       paginator.last();
       open();
   	}
    
    public void next() {
       paginator.next();
       open();
   	}
    
    public void previous() {
       paginator.previous();
       open();
    }

    public String constructTestString(Integer length) {
	    String sample = 'q w e r t y u i o p l k j h g f d s a z x c v b n m 1 2 3 4 5 6 7 8 9 0';
	    String[] chars = sample.split(' ');
	    String generatedString = '';
	    try {
		    for (Integer i = 0; i <= length; i++) {
		    	Integer num = Integer.valueof(Math.random()*chars.size());
		    	generatedString += String.valueof(chars[num]);
		    }
	    }
	    catch(Exception e) {}
	    if (generatedString == '') generatedString = 'random';
	    return generatedString;
	}

    public List<Map<String, String>> getUsersInfo(Integer count) {  
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();

        String endpoint = 'http://api.randomuser.me/?results=' + count + '&key=DQRR-6U1X-BOA7-S2OZ';
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(30000);

        HttpResponse response = httpProtocol.send(request);
        JSONParser parser = JSON.createParser(response.getBody());

        Map<String, Object> jsonresponce = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        List<Object> results = (List<Object>)jsonresponce.get('results');

        List<Map<String, String>> usersInfo = new List<Map<String, String>>();

        for(Object resultItem : results) {
            Map<String, Object> user = (Map<String, Object>)((Map<String, Object>)resultItem).get('user');   
            Map<String, Object> name = (Map<String, Object> )user.get('name');   
            Map<String, Object> location = (Map<String, Object> )user.get('location');   

            Map<String, String> userInfo = new Map<String, String>();
            userInfo.put('firstname', String.valueOf(name.get('first')));
            userInfo.put('lastname', String.valueOf(name.get('last')));
            userInfo.put('username', String.valueOf(user.get('username')));
            userInfo.put('email', String.valueOf(user.get('email')));
            userInfo.put('phone', String.valueOf(user.get('phone')));
            userInfo.put('street', String.valueOf(location.get('street')));
            userInfo.put('city', String.valueOf(location.get('city')));
            userInfo.put('state', String.valueOf(location.get('state')));
            userInfo.put('country', 'US');
            userInfo.put('postalcode', String.valueOf(location.get('zip')));

            usersInfo.add(userInfo);
        }
        return usersInfo;
    }

    public void testRun() {

    }

    public void check() {
        Helper.checkTheUpdatedFields();
        Helper.removeFromMainListOfDeletedObjects();
    }
}