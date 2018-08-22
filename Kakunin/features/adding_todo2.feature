Feature:

    Scenario: Adding todo
        Given I visit the "main" page
        And I wait for "visibilityOf" of the "addTodoForm" element
        And the "addTodoForm" element is visible
        When I fill the "addTodoForm" form with:
            | todoInput | My new todo |
        And I wait for "1" seconds
        And I press the "enter" key
        When I fill the "addTodoForm" form with:
            | todoInput | Another todo item! |
        And I wait for "1" seconds
        And I press the "enter" key
        Then there are "equal 2" "todos" elements
        Then I wait for "5" seconds