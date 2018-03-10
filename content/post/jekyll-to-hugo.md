---
title: 从Jekyll迁移到Hugo
date: 2018-03-10T15:48:40+08:00
tags:
  - Jekyll
  - Hugo
  - Travis CI
---

最近把博客从Jekyll迁移到了Hugo，在这里记录一下。

之前一直使用Jekyll，最大的原因是Github Pages原生支持Jekyll，
repo里只管理源代码就可以，不需要上传build之后的文件。
不过Jekyll也有许多不尽如人意的地方，主要是一下几点：

* 本地开发环境不容易配置。
  没有直接的可执行文件，需要安装ruby，gem，之后再安装jekyll
* Github Pages的build配置不能按照自己的需求定制。
  各种依赖的版本不能自己选择，也不能根据使用Jekyll的一些插件
* 编译速度慢。
  因为本站的文章太少，这一点倒是不是什么问题

# 内容迁移

博客从Jekyll迁移到Hugo，在考虑主题迁移的情况下，还是比较简单的。
Hugo的命令行可以直接从Jekyll导入文章，
```bash
hugo import jekyll /path/to/jekyll/root /target/path
```
这样可以直接导入文章，Jekyll中其他的静态文件会被放到`static`文件夹中。
这个命令比较简单，但并没有把所有事情干完。只是把Jekyll中的文章放到了Hugo中，
并且根据文件名里的时间，放到了front matter中，其他并没有改动。
文件名也仍然需要自己手动修改，去掉时间。

此外，Hugo使用的markdown，在语法上也与Jekyll有些差异，渲染出来的html也是有些不同。
这里可以在Hugo的配置文件里进行修改，也可以修改文章的语法。

# 自动编译

使用Jekyll的时候其实是不需要这一步的，直接推到github上就行了。
使用hugo，如果每次都是本地编译，然后把编译后的html文件推到github，
那就太不方便了。而且这样也不利于源码文件的管理。

## Travis CI

Travis CI是持续集成服务，并且对于Github上的public repo是免费使用的。
利用Travis CI，可以达到每次push到Github上的时候，自动build，
并推送到repo的特定的分支。

首先需要在Travis CI上开启repo的自动集成，然后在repo里添加`.travis.yml`。
Travis CI会根据这个文件，进行build。根据[Travis CI的文档][1]，
build过程分为几个阶段。一个静态博客的build，比较简单，
也不用所有的过程都用上。在`install`阶段安装hugo，`script`阶段调用hugo进行编译，
`after_success`阶段把生成的文件推到github上。这是本站的使用的配置。

```yml
# .traivs.yml
language: go
go:
 - '1.10'
branches:
  only:
  - source # 只有source分支的推送才触发构建
install:
  - wget /path/to/hugo/releases -O /tmp/hugo.tar.gz
  - mkdir -p bin
  - tar -xvf /tmp/hugo.tar.gz -C bin
script:
  - bin/hugo
after_success:
  - sh .travis/push.sh
```

```bash
# push.sh
setup_git() {
    git config --global user.name "travis@travis-ci.org"
    git config --global user.email "Travis CI"
}

commit_files() {
    git init
    git add .
    git commit -m"Travis build: $TRAVIS_BUILD_NUMBER"
}

push() {
    git remote add origin https://${GH_TOKEN}@github.com/yourname/yourrepo.git
    git push -f -u origin master
}

cd public
setup_git
commit_files
push
```

由于Travis CI并没有repo的push权限，所以直接推到repo上是会验证失败的。
`push.sh`里，`GH_TOKEN`是有`public_repo`权限的personal access token，
可以在<https://github.com/settings/tokens>申请，并在Travis CI上设置。

至此，Travis CI的自动build就完成了。


[1]: https://docs.travis-ci.com/user/customizing-the-build

