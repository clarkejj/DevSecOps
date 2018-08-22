'use strict';

const { BasePage } = require('kakunin');

class MainPage extends BasePage {
    constructor() {
        super();

        // define the main url for the page
        this.url = '/examples/react/#/';

        // whole form tag
        this.addTodoForm = $('.todoapp');

        // input field
        this.todoInput = $('input.new-todo');

        // list of currently added todos
        this.todos = $$('.todo-list .view');
        this.todoLabel = by.css('label');

        // first todo item in a list
        this.firstTodoItem = this.todos.get(0);
    }
}

module.exports = MainPage;
