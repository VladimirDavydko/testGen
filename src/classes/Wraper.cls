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