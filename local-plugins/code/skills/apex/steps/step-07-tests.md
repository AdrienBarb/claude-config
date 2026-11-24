---
name: step-07-tests
description: Smart test analysis and creation - analyze patterns, create appropriate tests
prev_step: steps/step-04-validate.md
next_step: steps/step-08-run-tests.md
---

# Step 7: Tests (Analysis & Creation)

Create the RIGHT tests: analyze the project's test infrastructure and conventions first, then write tests that follow them exactly. Test behavior, not implementation.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "07" "tests" "in_progress"
```

## 1. Analyze infrastructure and conventions

Discover the framework, config and test commands from package.json. Read similar existing test files (1 if economy_mode, 2-3 otherwise) and note: describe/it vs test() syntax, setup/teardown, mocking approach, assertion style, test-data handling.

## 2. Choose test types

| Implementation | Test type |
|----------------|-----------|
| API route | Integration (supertest/fetch) |
| Service/logic | Integration with real deps |
| Utility function | Unit |
| React component | Component (testing-library) |
| Full feature | Integration + E2E |

## 3. Plan and gate

Write a short test plan: framework, command, each test file with its cases (happy path, error cases, edge cases), mapped to the acceptance criteria.

- auto_mode → proceed.
- Otherwise ask via AskUserQuestion: **Create tests** (recommended) / **Add more tests** / **Modify approach** / **Skip tests**.

## 4. Create and check

Write the test files following the observed conventions exactly, then run the project's typecheck and list what was created.

If save_mode: append the analysis, plan and a `## Step Complete` block to `{output_dir}/07-tests.md`.

## Routing

Load `./step-08-run-tests.md`.
