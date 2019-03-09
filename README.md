# UnSub

This package provides a compatibility layer to [ReSub](https://github.com/Microsoft/ReSub) making it viable to code written in [CoffeeScript](https://coffeescript.org/).

## Installation

`npm install unsub --save-dev`

## Usage

```coffee
## TodosStore.coffee
import { StoreBase, AutoSubscribeStore } from "unsub"

export default new TodosStore = AutoSubscribeStore class extends StoreBase
  @Key_SomeFilter = "Key_SomeFilter"

  @autoSubscribeWithKey @Key_SomeFilter, getTodos: ->
    @_todosFiltered

  @autoSubscribe @key getTodosForUser: (username) ->
    @_todosByUser[username]

## TodoList.coffee
import { ComponentBase } from "unsub"
import TodosStore from "./TodosStore"

export class TodoList extends ComponentBase
  buildState: (props, bInit) ->
    todosFiltered: TodosStoreInstance.getTodos()
    userTodos: TodosStoreInstance.getTodosForUser @props.username

  render: ->
    <div>
    { @state.userTodos.map (todo) ->
      <Todo key={todo.id}>
        {todo.text}
      </Todo>
    }
    </div>
```

Above code is equivalent to this TypeScript code: <br id=ts>

```ts
/// TodosStore.ts
import { StoreBase, AutoSubscribeStore, autoSubscribe, key } from 'resub';

@AutoSubscribeStore
class TodosStore extends StoreBase {
    static Key_SomeFilter = "Key_SomeFilter";

    @autoSubscribeWithKey(TodosStore.Key_SomeFilter)
    getTodos() {
        return this._todosFiltered;
    }

    @autoSubscribe
    getTodosForUser(@key username: string) {
        return this._todosByUser[username];
    }
}

export = new TodosStore();

/// TodoList.tsx
import { ComponentBase } from 'resub';
import TodosStore from './TodosStore';

export class TodoList extends ComponentBase<{}, TodoListState> {
    protected _buildState(props: {}, initialBuild: boolean): TodoListState {
        return {
            todosFiltered: TodosStoreInstance.getTodos(),
            userTodos: TodosStoreInstance.getTodosForUser(this.props.username)
        }
    }

    render() {
      return (
          <div>
          { this.state.userTodos.map( todo => (
              <Todo key={ todo.id }>
                  { todo.text }
              </Todo>
          ))}
          </div>
      );
    }
}
```

## Overview

**UnSub** principially is used the same way as **ReSub**. One key difference is that decorators which take an argument do not return a decorator when called but instead are called with the arguments, followed by whatever they are decorating.

```coffee
# correct:
@autoSubscribeWithKey @Key_Filtered, getFilteredData: -> @filteredData
# incorrect:
@autoSubscribeWithKey(@Key_Filtered) getFilteredData: -> @filteredData
```

### Exports

#### Classes

- `StoreBase`
- `ComponentBase`

#### Class Decorators

- `AutoSubscribeStore`
- `DeepEqualityShouldComponentUpdate`
- `CustomEqualityShouldComponentUpdate COMPARE`

```coffee
MyStore = CustomEqualityShouldComponentUpdate shouldComponentUpdateCb, class extends StoreBase
  getData: -> @data
```

#### Member Function Decorators

- `@autoSubscribe`
- `@autoSubscribeWithKey KEY`
- `@disableWarnings`  
  Native to ReSub, undocumented.
- `@bound`  
  Helper which binds the function in the constructor.  
  This is necessary because fat arrows would bind to the constructor/class.

#### Parameter Decorators

- `@key [INDEX]`  
  Used outside parameter list. Index represents `arguments[index]`, is optional and defaults to 0.

```coffee
MyStore = AutoSubscribeStore class extends StoreBase
  @autoSubscribe @key 1, @bound getData: (a, b) ->
     # `b` is the key ^
    @data[b][a]
```

Note that member function and parameter decorators (prefixed with `@`) are actually static class members of `StoreBase`. This means that you must not have static members on your store that use the same identifier as a decorator you make use of inside the class body. It also means that you only need to import classes and class decorators.

For more information please refer to the [ReSub documentation](https://github.com/Microsoft/ReSub#readme).
