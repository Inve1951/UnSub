var makeClassDecorator,
    makeMemberFunctionDecorator,
    makeParamDecorator,
    splice = [].splice;
import * as resub from "resub";

makeClassDecorator = function (decorator) {
  return function (...args) {
    var _class, ref, ref1;

    ref = args, [...args] = ref, [_class] = splice.call(args, -1);

    if (args.length) {
      decorator = decorator(...args);
    }

    return (ref1 = decorator(_class)) != null ? ref1 : _class;
  };
};

makeMemberFunctionDecorator = function (decorator) {
  return function (...args) {
    var base, func, funcObj, name, ref, res;
    ref = args, [...args] = ref, [funcObj] = splice.call(args, -1);
    [[name, func]] = Object.entries(funcObj);

    if ((base = this.prototype)[name] == null) {
      base[name] = func;
    }

    if (args.length) {
      decorator = decorator(...args);
    }

    res = decorator(this.prototype, name, Reflect.getOwnPropertyDescriptor(this.prototype, name));

    if (res != null) {
      Reflect.defineProperty(this.prototype, name, res);
    }

    return {
      [name]: this.prototype[name]
    };
  };
};

makeParamDecorator = function (decorator) {
  return function (index, funcObj = 0) {
    var base, func, name;

    if (!funcObj) {
      [index, funcObj] = [funcObj, index];
    }

    [[name, func]] = Object.entries(funcObj);

    if ((base = this.prototype)[name] == null) {
      base[name] = func;
    }

    decorator(this.prototype, name, index);
    return {
      [name]: this.prototype[name]
    };
  };
};

export var StoreBase = function () {
  class StoreBase extends resub.StoreBase {
    constructor() {
      var __bound, i, len, name;

      super(...arguments);

      if (this.startedTrackingKey) {
        this._startedTrackingKey = this.startedTrackingKey;
      }

      if (this.stoppedTrackingKey) {
        this._stoppedTrackingKey = this.stoppedTrackingKey;
      }

      ({
        __bound
      } = this.constructor);

      if (__bound instanceof Array) {
        for (i = 0, len = __bound.length; i < len; i++) {
          name = __bound[i];
          this[name] = this[name].bind(this);
        }
      }
    }

    getSubscriptionKeys() {
      return this._getSubscriptionKeys(...arguments);
    }

    isTrackingKey() {
      return this._isTrackingKey(...arguments);
    }

    static bound(funcObj) {
      var name;
      [name] = Object.keys(funcObj);

      if (this.__bound == null) {
        this.__bound = [];
      }

      this.__bound.push(name);

      return funcObj;
    }

  }

  ;
  StoreBase.autoSubscribe = makeMemberFunctionDecorator(resub.autoSubscribe);
  StoreBase.autoSubscribeWithKey = makeMemberFunctionDecorator(resub.autoSubscribeWithKey);
  StoreBase.key = makeParamDecorator(resub.key);
  StoreBase.disableWarnings = makeMemberFunctionDecorator(resub.disableWarnings);
  return StoreBase;
}.call(this);
export var ComponentBase = class ComponentBase extends resub.ComponentBase {
  constructor() {
    super(...arguments);

    if (this.buildState) {
      this._buildState = function () {
        return this.buildState(...arguments);
      };
    }

    if (this.initStoreSubscriptions) {
      this._initStoreSubscriptions = function () {
        return this.initStoreSubscriptions(...arguments);
      };
    }

    if (this.componentDidRender) {
      this._componentDidRender = function () {
        return this.componentDidRender(...arguments);
      };
    }
  }

};
export var AutoSubscribeStore = makeClassDecorator(resub.AutoSubscribeStore);
export var DeepEqualityShouldComponentUpdate = makeClassDecorator(resub.DeepEqualityShouldComponentUpdate);
export var CustomEqualityShouldComponentUpdate = makeClassDecorator(resub.CustomEqualityShouldComponentUpdate);
export var Options = resub.Options;
export var Types = resub.Types;