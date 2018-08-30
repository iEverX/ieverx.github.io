---
title: Default method in interface
date: 2018-08-31T00:24:02+08:00
draft: true
tags:
  - Java
  - 语法
---

Java 中的`interface`是一组抽象方法的集合，是一组对外的接口。Java 8 之前，在`interface`中是没有方法体，的，只能在子类实现。如果是所有子类都一致的实现，标准方法是定义一个实现这个接口的抽象类，在抽象类中实现公共方法，子类集成这个抽象类，并实现各子类不同的方法。这样的写法并没有什么问题，只是啰嗦而已。在 Java 8 中，接口内可以实现 defaut method。所有实现改接口的类，如果没有重写这个方法，则使用接口中的实现。针对上面的场景，可以少写一个类。

此外，接口和抽象类的一个重要区别在于，一个类只能继承一个父类，却可以实现多个接口。在没有 default method 的时候，多个接口表示我们在子类中实现的方法变多了。假如一个接口内只有 default method，那么继承这个接口的类可以不用实现接口的方法，而自动的获得了一个方法。在一些场景下，可以利用这个方法给类增加一些 utils 方法。比如下边的代码，`Person`只需要继承`Jsonable`就可以自动的获得`toJson`方法。

```java
interface Jsonable {
    default String toJson() {
        return JsonSerializer.serialize(this);
    }
}
class Person implements Jsonable {
    private int id;
    private String name;
}
```

一些简单的 utils 方法，就可以不必定义一个 utils 类了。当然这是一种口味的问题，并不是所有人都喜欢这样一种方法的。此外，之所以说简答的 utils 方法可以这样实现，原因在于 java 的 interface 中不能有状态，所以有些是做不了的。比如缓存、log 等。并且现在 java 还是不支持接口中的私有方法，所以写一些复杂的方法在接口中，会暴露不必要的细节。好消息是 Java 9 已经支持了接口中的私有方法。

default method 是一种 [mixin][]，不过功能有限。而一些语言则提供更完善的 mixin 机制，比如 scala 的`trait`。`trait`是可以有状态的，从而对子类的的侵入会更少。对于 mixin 还不是很了解，可以参考下边的链接。

参考：\
[traits-java-8-default-methods][blog] \
[what-are-the-differences-and-similarties-between-scala-traits-vs-java-8-interfaces][so] \
[Mixin是什么概念?][zhihu]

[mixin]: https://zh.wikipedia.org/wiki/Mixin
[blog]: https://opencredo.com/traits-java-8-default-methods
[so]: https://stackoverflow.com/questions/16410298/what-are-the-differences-and-similarties-between-scala-traits-vs-java-8-interfa
[zhihu]: https://www.zhihu.com/question/20778853