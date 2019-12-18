###
#                   UnSub
# ReSub compatibility layer for CoffeeScript
#             (c)2019 - square
#
#
#
# Example:
##TypeScript:

import { StoreBase, AutoSubscribeStore, autoSubscribe, ComponentBase, key } from 'resub';
@AutoSubscribeStore
class TodosStore extends StoreBase {
  static Key_Whatever = "Key_Whatever";
  @autoSubscribeWithKey(TodosStore.Key_Whatever)
  getTodos() { return this._todosWhatever; }
  @autoSubscribe
  getTodosForUser(@key username: string) {
      return this._todosByUser[username];
  }
}
class TodoList extends ComponentBase<{}, TodoListState> {
  protected _buildState(props: {}, initialBuild: boolean, incomingState: {}): TodoListState {
      return {
          todosWhatever: TodosStoreInstance.getTodos(),
          userTodos: TodosStoreInstance.getTodosForUser(this.props.username)
      }
  }
}

##CoffeeScript:

import { StoreBase, AutoSubscribeStore, autoSubscribe, ComponentBase, key } from "unsub"
TodosStore = AutoSubscribeStore class extends StoreBase
  @Key_Whatever = "Key_Whatever"
  @autoSubscribeWithKey @Key_Whatever, getTodos: ->
    @_todosWhatever
  @autoSubscribe @key getTodosForUser: (username) ->
    @_todosByUser[username]

class TodoList extends ComponentBase
  buildState: (props, state, bInit) ->
    todosWhatever: TodosStoreInstance.getTodos()
    userTodos: TodosStoreInstance.getTodosForUser @props.username

###




import * as resub from "resub"

makeClassDecorator = (decorator) -> (args..., _class) ->
  decorator = decorator args... if args.length
  decorator(_class) ? _class

makeMemberFunctionDecorator = (decorator) -> (args..., funcObj) ->
  [[name, func]] = Object.entries funcObj
  @::[name] ?= func
  decorator = decorator args... if args.length
  res = decorator @::, name, Reflect.getOwnPropertyDescriptor @::, name
  Reflect.defineProperty @::, name, res if res?
  [name]: @::[name]

# `index` is optional when 0
makeParamDecorator = (decorator) -> (index, funcObj = 0) ->
  [index, funcObj] = [funcObj, index] unless funcObj
  [[name, func]] = Object.entries funcObj
  @::[name] ?= func
  decorator @::, name, index
  [name]: @::[name]

__bound = Symbol()

export class StoreBase extends resub.StoreBase
  constructor: ###(throttleMs = 0, bypassTriggerBlocks = no)### ->
    super arguments...
    if @startedTrackingKey
      @_startedTrackingKey = @startedTrackingKey
    if @stoppedTrackingKey
      @_stoppedTrackingKey = @stoppedTrackingKey
    {[__bound]: bound} = @constructor
    if bound instanceof Array then for name in bound
      @[name] = @[name].bind this

  getSubscriptionKeys: -> @_getSubscriptionKeys arguments...
  isTrackingKey: -> @_isTrackingKey arguments...

  @autoSubscribe: makeMemberFunctionDecorator resub.autoSubscribe
  @autoSubscribeWithKey: makeMemberFunctionDecorator resub.autoSubscribeWithKey
  @key: makeParamDecorator resub.key
  @disableWarnings: makeMemberFunctionDecorator resub.disableWarnings

  @bound: (funcObj) ->
    [name] = Object.keys funcObj
    @[__bound] ?= []
    @[__bound].push name
    funcObj

export class ComponentBase extends resub.ComponentBase
  constructor: ->
    super arguments...
    # The decoration is so you can still bind them with CS syntax
    if @buildState then @_buildState = (props, bInit, state, args...) ->
      @buildState props, state, bInit, args...
    if @componentDidRender then @_componentDidRender = ->
      @componentDidRender arguments...


export AutoSubscribeStore =
  makeClassDecorator resub.AutoSubscribeStore

export DeepEqualityShouldComponentUpdate =
  makeClassDecorator resub.DeepEqualityShouldComponentUpdate

export CustomEqualityShouldComponentUpdate =
  makeClassDecorator resub.CustomEqualityShouldComponentUpdate


export Options = resub.Options
export Types = resub.Types

export setPerformanceMarkingEnabled = resub.setPerformanceMarkingEnabled
export formCompoundKey = resub.formCompoundKey






# Notes:
# // var __decorate = function (decorators, target, key, desc) {
# //   var c, rr, d, i, t;
# //   c = arguments.length;
# //
# //   if (c < 3)
# //     rr = target;
# //   else if (null === desc)
# //     rr = desc = Object.getOwnPropertyDescriptor(target, key)
# //   else
# //     rr = desc
# //
# //   for (i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) {
# //     if (c < 3)
# //       t = d(rr);
# //     else if (c > 3)
# //       t = d(target, key, rr);
# //     else
# //       t = d(target, key);
# //     rr = t || rr;
# //   }
# //   if (c > 3 && rr) Object.defineProperty(target, key, rr)
# //   return rr;
# // };
# //
# // import { StoreBase, AutoSubscribeStore, autoSubscribe } from 'resub';
# // let TodosStore = class TodosStore extends StoreBase {
# //   constructor() {
# //     super(...arguments);
# //     this.todos = [];
# //   }
# //   addTodo(todo) {
# //     this.todos = this.todos.concat(todo);
# //     this.trigger();
# //   }
# //   getTodos() {
# //     return this.todos;
# //   }
# // };
# //
# // __decorate([
# //   autoSubscribe
# // ], TodosStore.prototype, "getTodos", null);
# // TodosStore = __decorate([
# //   AutoSubscribeStore
# // ], TodosStore);
# //
# // var __param = function (paramIndex, decorator) {
# //   return function (target, key) {
# //     decorator(target, key, paramIndex);
# //   }
# // }
#
# // The emit for a method is:
# //
# //   __decorate([
# //       dec,
# //       __param(0, dec2),
# //       __metadata("design:type", Function),
# //       __metadata("design:paramtypes", [Object]),
# //       __metadata("design:returntype", void 0)
# //   ], C.prototype, "method", null);
# //
# // The emit for an accessor is:
# //
# //   __decorate([
# //       dec
# //   ], C.prototype, "accessor", null);
# //
# // The emit for a property is:
# //
# //   __decorate([
# //       dec
# //   ], C.prototype, "prop");
