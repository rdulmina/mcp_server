import ballerina/time;

// In-memory store of tasks, keyed by task ID. Protected by a lock since the
// MCP service may handle concurrent tool invocations.
isolated map<Task> taskStore = {};

// Monotonically increasing counter used to assign unique task IDs.
isolated int nextTaskId = 1;

// Generates the next unique task ID.
isolated function generateTaskId() returns int {
    lock {
        int id = nextTaskId;
        nextTaskId += 1;
        return id;
    }
}

// Creates a new task from the given input and stores it.
isolated function addTask(NewTaskInput input) returns Task {
    int taskId = generateTaskId();
    string createdAt = time:utcToString(time:utcNow());
    Task newTask = {
        id: taskId,
        title: input.title,
        description: input.description,
        completed: false,
        createdAt: createdAt
    };
    lock {
        taskStore[taskId.toString()] = newTask.clone();
    }
    return newTask;
}

// Returns all stored tasks.
isolated function getAllTasks() returns Task[] {
    lock {
        return taskStore.toArray().clone();
    }
}

// Returns a single task by ID, or () if it does not exist.
isolated function findTaskById(int taskId) returns Task? {
    lock {
        Task? found = taskStore[taskId.toString()];
        return found.clone();
    }
}

// Updates an existing task with the given fields. Returns the updated task,
// or () if no task exists with the given ID.
isolated function updateTask(int taskId, TaskUpdateInput updateInput) returns Task? {
    lock {
        Task? existingTask = taskStore[taskId.toString()];
        if existingTask is () {
            return ();
        }
        string? updatedTitle = updateInput.title;
        if updatedTitle is string {
            existingTask.title = updatedTitle;
        }
        string? updatedDescription = updateInput.description;
        if updatedDescription is string {
            existingTask.description = updatedDescription;
        }
        boolean? updatedCompleted = updateInput.completed;
        if updatedCompleted is boolean {
            existingTask.completed = updatedCompleted;
        }
        taskStore[taskId.toString()] = existingTask;
        return existingTask.clone();
    }
}

// Deletes a task by ID. Returns true if a task was removed, false otherwise.
isolated function deleteTaskById(int taskId) returns boolean {
    lock {
        Task? removedTask = taskStore.removeIfHasKey(taskId.toString());
        return removedTask is Task;
    }
}
