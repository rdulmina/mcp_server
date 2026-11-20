// Represents a single task managed by the Task Manager MCP server.
public type Task record {|
    int id;
    string title;
    string description?;
    boolean completed;
    string createdAt;
|};

// Input required to create a new task.
public type NewTaskInput record {|
    string title;
    string description?;
|};

// Input used to update an existing task's fields.
public type TaskUpdateInput record {|
    string title?;
    string description?;
    boolean completed?;
|};
