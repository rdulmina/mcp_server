import ballerina/mcp;

configurable int serverPort = 9090;

listener mcp:Listener taskMcpListener = check new (serverPort);

@mcp:ServiceConfig {
    info: {
        name: "Task Manager MCP Server",
        version: "1.0.0",
        description: "Exposes tools to create, list, update, complete, and delete tasks in a simple in-memory task manager."
    },
    sessionMode: mcp:STATELESS
}
service mcp:Service /mcp on taskMcpListener {

    @mcp:Tool {
        description: "Create a new task with a title and an optional description."
    }
    remote function createTask(string title, string? description = ()) returns Task|error {
        NewTaskInput newTaskInput = {title, description};
        return addTask(newTaskInput);
    }

    @mcp:Tool {
        description: "List all tasks currently stored in the task manager."
    }
    remote function listTasks() returns Task[]|error {
        return getAllTasks();
    }

    @mcp:Tool {
        description: "Get the details of a single task by its ID."
    }
    remote function getTask(int taskId) returns Task|error {
        Task? task = findTaskById(taskId);
        if task is () {
            return error(string `Task not found for ID: ${taskId}`);
        }
        return task;
    }

    @mcp:Tool {
        description: "Update an existing task's title, description, and/or completed status."
    }
    remote function editTask(int taskId, string? title = (), string? description = (), boolean? completed = ())
            returns Task|error {
        TaskUpdateInput taskUpdateInput = {title, description, completed};
        Task? updatedTask = updateTask(taskId, taskUpdateInput);
        if updatedTask is () {
            return error(string `Task not found for ID: ${taskId}`);
        }
        return updatedTask;
    }

    @mcp:Tool {
        description: "Mark a task as completed."
    }
    remote function completeTask(int taskId) returns Task|error {
        TaskUpdateInput taskUpdateInput = {completed: true};
        Task? updatedTask = updateTask(taskId, taskUpdateInput);
        if updatedTask is () {
            return error(string `Task not found for ID: ${taskId}`);
        }
        return updatedTask;
    }

    @mcp:Tool {
        description: "Delete a task by its ID."
    }
    remote function deleteTask(int taskId) returns string|error {
        boolean wasDeleted = deleteTaskById(taskId);
        if !wasDeleted {
            return error(string `Task not found for ID: ${taskId}`);
        }
        return string `Task ${taskId} deleted successfully.`;
    }
}
