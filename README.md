# UnSub

This package provides a compatibility layer to [ReSub](https://github.com/Microsoft/ReSub) making it viable to code written in [CoffeeScript](https://coffeescript.org/).

## Installation

`npm install unsub resub`

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
  buildState: (props, state, bInit) ->
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
    protected _buildState(props: {}, initialBuild: boolean, state: {}): TodoListState {
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


## Breaking Change in v2.0.0

**ReSub** `v2.0.0-rc.2` introduced a new argument to stores' `_buildState` function.

```coffee
# old:
buildState: (props, bInit) ->
_buildState: (props, bInit) ->
# new:
buildState: (props, state, bInit) ->
_buildState: (props, bInit, state) ->
```

### Reasoning for the new argument:

Changes in ReSub/React made it unreliable and bugprone to use `this.state` inside `_buildState`. It was not always updated and would reflect old state. As a workaround they added `state` as a third argument.

### Reasoning for breaking the old signature:

There's 2 parts to that answer.

Firstly it feels far more natural to have `state` follow `props`. Most (if not all these days) of React's functions taking both `props` and `state` have them as the first 2 arguments and in that same order; especially if you use [preact](https://preactjs.com/) (which you should).

Secondly, if you made use of `@state` inside `buildState` there's a high chance it's buggy now (breaking change in React/ReSub). To fix that you are required to go thru your code and switch to using the `state` argument. While doing that you may as well switch to the new (and better) signature.

Yes, if you aren't affected by \#2 `bInit` still moved and I broke your components. The above 2 reasons are big enough to warrant you do a search and replace.


## Overview

**UnSub** principially is used the same way as **ReSub**. One key difference is that decorators which take an argument do not return a decorator when called but instead are called with the arguments, followed by whatever they are decorating.

```coffee
# correct:
@autoSubscribeWithKey @Key_Filtered, getFilteredData: -> @filteredData
# incorrect:
@autoSubscribeWithKey(@Key_Filtered) getFilteredData: -> @filteredData
```

Furthermore it allows you to omit the underscore on your overrides. E.g. `buildState` instead of `_buildState`. This more closely follows React's style of writing components.

Also see v2's breaking changes in the previous section.

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
