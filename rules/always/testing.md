Write tests that express the intention and expected behavior of the code.
A newly written test must fail before the code that satisfies it is written.
Write only the code necessary to make the failing test pass.
After a test passes, you may propose a refactor.
Justify any proposed refactor.
A refactor must not change the code's observable behavior.
Run the test suite after each step and confirm the result the step expects: failing after a new test, passing after an implementation or a refactor.
Do not modify code in a way that circumvents existing tests.
Never weaken, skip, or delete an existing test to make code pass.
Every behavior an implementation adds is covered by a test.
Keep each test minimal while still representative of the behavior it guarantees.
Keep each test focused on one behavior.
Test user-facing behavior through the actions a user would take, not implementation details.
Test error-handling code paths.
Avoid brittle assertions such as matching exact error message text.
Keep unit tests fast.
When the full test suite is too slow to run, run only the tests scoped to the feature.
Specify the expected output data for each integration test.
Verify data transformation as it flows through each component under test.
Mock external API calls in integration tests.
Mock external data results with realistic, accurate data.
Assert that mocked external calls receive valid data.
When code dispatches asynchronous work, test that it is dispatched and that it produces the expected result.
