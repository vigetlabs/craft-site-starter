---
name: process-todo
description: Reads a TODO.md file at the root of the project, executing tasks sequentially. Commits after each step, updating the TODO.md to mark progress.
allowed-tools: Bash, Write, Read, Edit
---

# Process TODO list

Reads the `TODO.md` file located at the root of the repository, executes its items one by one sequentially, commits changes, and updates `TODO.md` to reflect progress.

## Prerequisites

- There must be a `TODO.md` file in the root of the project.
- The `TODO.md` should use standard Markdown formatting. E.g., task lists like `- [ ] Task 1`, `- [x] Task 2`.

## Execution Steps

Follow these steps iteratively until all tasks in `TODO.md` are completed:

### 1. Read TODO.md

Read the contents of the `TODO.md` file. Identify the first incomplete task (e.g. `- [ ] ...`).

### 2. Plan and Execute

Analyze the identified task. Make a plan and execute the necessary changes to fulfill the requirements of the task. Do not try to complete multiple tasks at once. Focus on the current task.

### 3. Verify

Verify the changes. Run linting, formatting, and tests as necessary to ensure the codebase remains stable.
Use the appropriate tools (e.g., `npm run lint`, `npm run format`, `ddev exec composer run ecs-check`, etc.).

### 4. Update TODO.md

Update the `TODO.md` file, changing the `- [ ]` for the completed task to `- [x]`.

### 5. Commit

Commit the changes for the task along with the `TODO.md` update. Use a descriptive commit message based on the task description.

### 6. Loop

Return to Step 1 and repeat until all tasks in `TODO.md` are marked as complete.
