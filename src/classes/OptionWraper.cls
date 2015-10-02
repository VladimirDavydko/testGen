public class OptionWraper {
    public String label { get; set; }
    public Boolean isActive { get; set; }
    public Double probability { get; set; }

    public optionWraper(String label) {
        this.label = label;
    }
}