public class FieldsWraper {
    public String name { get; set; }
    public String value { get; set; }
    public String fieldType { get; set; }
    public Boolean isCheked { get; set; }
    public List<SelectOption> options { get; set; }
    public Boolean isRequired { get; set; }

    public List<OptionWraper> optionWraperList { get; set; }
    
    public FieldsWraper(){}
    
    public FieldsWraper(FieldsWraperJSON wraper) {
    	name = wraper.name;
    	value = wraper.value;
    	fieldType = wraper.fieldType;
    	isCheked = wraper.isCheked;
    	options = new List<SelectOption>();
        isRequired = wraper.isRequired;

        optionWraperList = wraper.optionWraperList;
    	
        for(String item : wraper.options) {
        	String[] optionData = item.split('---', -3);
        	if(optionData.size() != 2) continue;
        	options.add(new SelectOption(optionData[0], optionData[1]));
        }
    }
}