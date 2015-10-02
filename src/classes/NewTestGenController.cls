public class NewTestGenController {

    public static List<String> objectNames {get; set;}
    public static Map<String, Schema.SObjectType> globalDescribe {
    	get {
    		if (globalDescribe == NULL) {
    			globalDescribe = Schema.getGlobalDescribe();
    			return globalDescribe;
    		}
    		else {
    			return globalDescribe;
    		}
    	}
    	set;
	}

    public NewTestGenController() {}

    @RemoteAction
    public static List<String> getObjectNames() {
    	
        objectNames = new List<String>{'Lead', 'Account', 'Contact', 'Contract', 'Note', 'Opportunity', 'Case', 'Order', 'User', 'Profile'};
        
        for(Schema.SObjectType objTyp : globalDescribe.Values()) {
        
            Schema.DescribeSObjectResult describe = objTyp.getDescribe();
            
            Boolean isAccessible = describe.isAccessible();
            Boolean isCreateable = describe.isCreateable();
            Boolean isQueryable = describe.isQueryable();
            Boolean isUpdateable = describe.isUpdateable();
            Boolean isCustom = describe.isCustom();
            
            if (isAccessible && isCreateable && isQueryable && isUpdateable && isCustom) {
                String name = objTyp.getDescribe().getName();
                objectNames.add(name);
            }
        }
        objectNames.sort();
        return objectNames;
    }
    
    @RemoteAction
    public static String getFieldAndDependencies(String objName) {
    	
        List<FileldWraper> fieldTypeMap = new  List<FileldWraper>();
        Map<String, Schema.SobjectField> mainMap = globalDescribe.get(objName).getDescribe().fields.getMap();
        List<DependencyWraper> dependencies = new List<DependencyWraper>();
        for(String fieldName : mainMap.keySet()) {
        	if (fieldName == 'id') continue;
    		String fieldType = mainMap.get(fieldName).getDescribe().getType().name();
        	Schema.DescribeFieldResult describeField = mainMap.get(fieldName).getDescribe();
            Boolean isRequired = describeField.isCreateable() 
    						 && !describeField.isNillable()
    						 && !describeField.isDefaultedOnCreate()
    						 &&  describeField.isFilterable()
    						 &&  describeField.isGroupable();
    						 
		 	Boolean accessible = describeField.isCreateable()
	    					 &&  describeField.isFilterable();
        	if (isRequired) {
            	fieldTypeMap.add(new FileldWraper(fieldName, fieldType, 'true'));
        	}
        	else if (accessible) {
            	fieldTypeMap.add(new FileldWraper(fieldName, fieldType));
        	}
        	
        	if (accessible && fieldType == 'REFERENCE') {
        		for (Schema.sObjectType ref : describeField.getReferenceTo()) {
        			dependencies.add(new DependencyWraper(objName, fieldName, String.valueof(ref)));
        		}
        	}
        }
        return JSON.serialize(new ImportData(fieldTypeMap, dependencies));
    }
    
    public class FileldWraper {
    	
    	public String Name {get; set;}
    	public String Type {get; set;}
    	public String Required {get; set;}
    	
    	public FileldWraper(String Name, String Type) {
    		this.Name = Name;
    		this.Type = Type;
    	}
    	
    	public FileldWraper(String Name, String Type, String Required) {
    		this.Name = Name;
    		this.Type = Type;
    		this.Required = Required;
    	}
    }
    
    public class DependencyWraper {
    	
    	public String name1 {get; set;}
    	public String field1 {get; set;}
    	public String name2 {get; set;}
    	
    	public DependencyWraper(String Name, String Field, String TargetName) {
    		this.name1 = Name;
    		this.field1 = Field;
    		this.name2 = TargetName;
    	}
    }
    
    public class ImportData {
    	
    	public List<FileldWraper> fields {get; set;}
    	public List<DependencyWraper> dependencies {get; set;}
    	
    	public ImportData(List<FileldWraper> fields, List<DependencyWraper> dependencies) {
    		this.fields = fields;
    		this.dependencies = dependencies;
    	}
    }
    
    
}