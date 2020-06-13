+++
title = "在只有类名时使用 Jackson 反序列化 Java 对象"
date = 2019-04-21T16:41:00+08:00
aliases = ["post/jackson-deserialize-with-only-class-names"]

[taxonomies]
tags = ["Jackson", "Java"]
+++

# 反序列化

Java 里，用 Jackson 序列号和反序列化，非常简单。序列化不是本文关心的内容，不谈。反序列的接口，基本下边这两个接口。

```java
<T> T readValue(String content, Class<T> valueType);
<T> T readValue(String content, TypeReference valueTypeRef);
```

使用 `Class<T>` 的接口，返回的是一个类型为 `T` 的对象。接口的声明很直接，使用也比较舒服。不过当需要反序列的是带有参数的类型，比如 `List` 等，这个接口提供的信息就缺失了一些，那就是 `List` 的类型参数。在语法上，`readValue(s, List<Type>.class)` 是行不通的。而，`List<Dog>` 和 `List<Cat>` 显然不同，在反序列化时，我们期望得到元素类型不同的 `List` 。

Java 中，不允许 `List<Type>.class` 的写法，是因为类型擦除。编译之后，只有 `List` 这个 rawType。为了解决这个问题，Jackson 提供了 `TypeRefernece`，来保存类型参数信息。既然可以保存，显然，类型擦除并没有完全地把所有的类型参数的信息都丢掉。实际上，可以通过反射来获取类的泛型信息，方法是通过 `Class#getGenericSuperclass` 获取泛型父类，返回的类型是 `Type`。如果父类实际上没有类型参数，则实际上是个 `Class`，否则，是 `ParameterizedType`。看下 `TypeReference` 的具体实现，

```java
// 删除了无关代码、注释、空行
public abstract class TypeReference<T> {
    protected final Type _type;
    protected TypeReference() {
        Type superClass = getClass().getGenericSuperclass();
        if (superClass instanceof Class<?>) { // sanity check, should never happen
            throw new IllegalArgumentException("Internal error: TypeReference constructed without actual type information");
        }
        _type = ((ParameterizedType) superClass).getActualTypeArguments()[0];
    }
    public Type getType() { return _type; }
}
```

注意 `TypeReference` 是一个抽象类，这意味着实例化时都是要创建一个子类。有了 `TypeRerence`，反序列化就没有问题了。

# 没有类型的具体信息

这里其实还有个问题，假如我没有类的实际信息，只有类的名字以及类型参数的名字，怎么来反序列化呢？我碰到这个问题，是在尝试写一个简单的 RPC，序列化方式就是用的 json。在传递参数时，客户端只能把参数的类型通过字符串传递，需要在服务端解析出来。

`TypeReference` 的构造函数，要求必须有类型参数。然而，即使通过类名，获得了对应的 `Class` 实例，也没有办法转变成字面量去创建一个 `TypeReference`。解决办法其实很简单，重写 `getType` 方法，因为 `TypeReference` 的目的就只是提供一个 `getType` 方法。

```java
class CustomeTypeRef<T> extends TypeReference<T> {
        private Class<?> rawType, paramType;
        protected MyTypeRef(Class<?> rawType, Class<?> paramType) {
            this.rawType = rawType;
            this.paramType = paramType;
        }
        @Override
        public Type getType() {
            return new ParameterizedType() {
                @Override
                public Type[] getActualTypeArguments() {
                    return new Type[]{paramType};
                }
                @Override
                public Type getRawType() {
                    return rawType;
                }
                @Override
                public Type getOwnerType() {
                    return null;
                }
            };
        }
    }
}
```

虽然参数类型 `T` 已经不需要了，但是必须得有。因为在 `TypeReference` 的默认构造函数，强制必须有参数类型。

看起来很简单的样子啊。