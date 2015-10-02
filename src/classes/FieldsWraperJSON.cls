public class FieldsWraperJSON {
        public String name {get; set;}
        public String value {get; set;}
        public String fieldType {get; set;}
        public Boolean isCheked {get;set;}
        public List<string> options {get;set;}
        public Boolean isRequired { get; set; }

        public List<OptionWraper> optionWraperList { get; set; }
        
        public FieldsWraperJSON(){}
        
        public FieldsWraperJSON(FieldsWraper wraper) {
        	
        	name = wraper.name;
        	value = wraper.value;
        	fieldType = wraper.fieldType;
        	isCheked = wraper.isCheked;
        	options = new List<String>();
            isRequired = wraper.isRequired;

            optionWraperList = wraper.optionWraperList;
        	
	        for(SelectOption item : wraper.options) {
	        	if(fieldType == 'PICKLIST' || fieldType == 'MULTIPICKLIST') options.add(item.getLabel() + '---' + item.getValue());
	        	else options = new List<String>{'empty'};
	        }
        }
    }