import Time "mo:base/Time";

module {
    public type Homework = { 
        title : Text;
        description : Text;
        dueDate : Time.Time;
        completed : Bool;
    };
}