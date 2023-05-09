import Time "mo:base/Time";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";


actor HomeworkDiary {

    public type Homework = { 
        title : Text;
        description : Text;
        dueDate : Time.Time;
        completed : Bool;
    };

    let HomeworkDiary = Buffer.Buffer<Homework>(10);

    // Add a new homework task
    public func addHomework (homework : Homework) : async Homework{
        return Nat; //homework id
    };

    // Get a specific homework task by id
    public query func getHomework (id: Nat) : async Result.Result<Homework, Text>{
        return id;
    };

    // Update a homework task's title, description, and/or due date
    public func updateHomework (id: Nat, homework : Homework) : async Result.Result<(), Text>{
        return id;
    };

    // Mark a homework task as completed 
    public func markAsCompleted (id: Nat) :async Result.Result<(), Text>{
        return id;
    };
    
    // Delete a homework task by id
    public func deleteHomework (id: Nat): async Result.Result<(), Text>{
        return id;
    };

    // Get the list of all homework tasks
    public query func getAllHomework() : async [Homework]{
        return id;
    };

    // Get the list of pending (not completed) homework tasks
    public query func getPendingHomework(): async [Homework]{
        return id;
    };

    // Search for homework tasks based on a search terms
    public query func searchHomework(searchTerm: Text): async [Homework]{
        return id;
    };
};