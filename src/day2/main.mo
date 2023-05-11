import Time "mo:base/Time";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Types "Types";
import Error "mo:base/Error";


actor HomeworkDiary {

    public type Homework = Types.Homework;

    let HomeworkDiary = Buffer.Buffer<Homework>(10);


    // Add a new homework task
    public func addHomework (homework : Homework) : async Nat{
        let index = HomeworkDiary.size();
        HomeworkDiary.add(homework);
        return index;
    };

    // Get a specific homework task by id
    public query func getHomework (id: Nat) : async Result.Result<Homework, Text>{
        let catchHomework : ?Homework = HomeworkDiary.getOpt(id);
        switch (catchHomework){
            case (null){
                #err ("WHAT?! I can't find your homework!");
            };
            case (?catchHomework){
                #ok catchHomework;
            };
        };
    };

    // // Update a homework task's title, description, and/or due date
    public func updateHomework (id: Nat, homework : Homework) : async Result.Result<(), Text>{
        let catchHomework = HomeworkDiary.getOpt(id);
        switch (catchHomework){
            case (null){
                #err ("WHAT?! I can't find your homework!");
            };
            case (catchHomework){
                HomeworkDiary.put(id, homework);
                #ok ();
            };
        };
    };

    // // Mark a homework task as completed 
    public func markAsCompleted (id: Nat) :async Result.Result<(), Text>{
        let catchHomework = HomeworkDiary.getOpt(id);
        switch (catchHomework){
            case(null){
                return #err("WHAT?! I can't find your homework!");
            };
            case (catchHomework){
                var newWork : Homework = HomeworkDiary.get(id);
                var newHomework = {
                    title = newWork.title;
                    description = newWork.description;
                    dueDate = newWork.dueDate;
                    completed = true;
                };
                HomeworkDiary.put(id, newHomework);
                #ok();
            };
        };
    };
    
    // // Delete a homework task by id
    public func deleteHomework (id: Nat): async Result.Result<(), Text>{
        let catchHomework : ?Homework = HomeworkDiary.getOpt(id);
        switch (catchHomework){
            case(null){
                return #err("WHAT?! I can't find your homework!");
            };
            case (catchHomework){
                var x = HomeworkDiary.remove(id);
                return #ok();
            };
        };
    };

    // Get the list of all homework tasks
    public query func getAllHomework() : async [Homework]{
        return Buffer.toArray<Homework>(HomeworkDiary);
    };

    // // Get the list of pending (not completed) homework tasks
    public query func getPendingHomework(): async [Homework]{
        var copyList = Buffer.clone(HomeworkDiary);
        copyList.filterEntries(func(_, work) = work.completed == false);
        Buffer.toArray<Homework>(copyList);
    };

    // // Search for homework tasks based on a search terms
    public query func searchHomework(searchTerm: Text): async [Homework]{
        var search = Buffer.clone(HomeworkDiary);
        search.filterEntries(func(_, work) = Text.contains(work.title, #text searchTerm) or Text.contains(work.description, #text searchTerm));
        Buffer.toArray<Homework>(search);
    };
};