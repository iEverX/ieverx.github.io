+++
title = "neovim 插件 denote.nvim"
date = 2019-05-03T21:15:39+08:00
aliases = ["post/neovim-plugin-denite"]

[taxonomies]
tags = ["neovim"]
+++

# neovim

hyperextensible Vim-based text editor。这是 [neovim][] 官网对其的定义。目前，neovim 仍然在快速迭代，并且现在的版本（v0.3.5）已经可用。neovim 和 vim 在基本使用时兼容的，配置文件也基本是兼容的。因为我不是 vim 重度用 户，所以并没有发现 vim 中可用但是 neovim 中不可用的功能。目前我已经全部切换到 neovim 了。                 

# denite.nvim

[denite.nvim] 是 neovim 的一个插件，在 vim 8 中也能使用。denite.nvim 利用了异步特性，性能相比上一代的unite.vim 有了很大的提升。denite 作者对其的描述是，“Dark powered asynchronous unite all interfaces for Neovim/Vim8”。说实话，从这句话，我是根本没明白这个插件到底做的是啥。不过看到一些推荐这个插件的地方，是用作 fuzzy finder 的，所以还是装了看了下。

简单地说，denite 是给 neovim 中提供了类似于 VSCode、Atom 中类似于 Ctrl-P 的功能。其实也有其他的插件提供类 似的功能，比如 [fzf.vim][]，[ctrlp.vim][]。不过我没有用过这些插件，所以本文不会对比。

denite 的配置比较复杂，幸而文档非常完善。denite 中，通过 source 收集不同的可以访问的对象。利用 `:Denite` 指令，列出 source 收集的对象，进而针对选择的对象，执行不同的操作。

先来个简单的例子，`:Denite file/rec`，查看当前目录下的所有的文件列表，rec 的意思是递归。所以，也有一个 file 的 source，只会显示当前目录下最顶层的文件。执行命令后，会有一个新的 buffer，列出所有的内容，称为 denite buffer。denite buffer 和普通的 vim buffer 不太一样， 可以认为是一个临时的 buffer。denite buffer 的操作方式和 vim buffer 也是不同的，但是也有两种模式，Insert 和 Normal。执行指令后，默认会进入 Insert 模式，denite 会根据用户的输入，过滤掉不匹配的候选项，默认的匹配方法是 fuzzy match，和 VSCode 中的 Ctrl-P 是一样的。选定候选之后，可以执行不同的操作，比如预览、打开、在另一个 buffer 打开等等。

## source

source 是 denite 的核心概念。denite 可选择的候选都是由 source 提供的。简单而言，每个 source 提供了一个候选对象的（有序）集合。比如前边提到的 file/rec，内置的 source 还包括比如 colorscheme、buffer、command 等。source 可以有参数，在执行 `:Denite` 时，可以传递参数。比如 file/rec，可以接受一个参数作为搜索的目录，如果参数省略，则使用当前目录。除了参数，source 还可以通过 `denite#custom#var` 自定义一些变量（variable）。比如

```vim
call denite#custom#var('file/rec', 'command', ['git', 'ls-files', '-co', '--exclude-standard'])
```

这行代码自定义了 file/rec 这个 source 的 `command` 变量，这个变量是 source 获取文件列表的命令。在 Unix 环境下，默认的是使用 `find` 的。自定义之后，则变成了 `git ls-files -co --exclude-standard`。不同的 soruce 的参数以及可以自定义的变量都不同，具体的需要查看文档了。

## denite buffer

source 收集的对象，都是列在 denite buffer 里，用户可以通过输入来过滤搜索结果。默认的设置下，进入 denite buffer 是处于 Insert 模式，这时用户可以进行输入过滤结果。在 Insert 模式下，输入 `<tab>`，可以选择一些可用的 action。不同的结果，可用的 action 也不同。结果又不同的类型，比如 file、buffer 等。不同的类型支持不同的 action 集合。

和 vim buffer 一样，denite buffer 也支持自定义 map。当然就不是 vim 默认的定义 map 的方式了。denite 中使用 `denite#custom#map` 定义 map。来个例子

```vim
call denite#custom#map('normal', '<tab>', '<denite:do_action:preview>', 'noremap')
```

这个例子，把 Normal 模式下的 `<tab>` 键，映射为预览操作。最后的 `noremap` 和 vim 中的意义一样，因为默认 denite 也会递归的解析映射的定义。定义了映射后，denite buffer 的操作和 vim 就没有区别了。现在 VSCode 中也是可以使用 vim 的，但是只能在编辑区。使用 Ctrl-P 的时候，可能还是不得不依赖方向键。在 denite 里就没有了这个问题。

## 预览主题的例子

denite 内置了 colorscheme 的 source，收集了所有已安装的主题。本来，在 vim 中切换主题，不是很方便，因为没有预览功能，只能 `:color <theme>` 选定主题，不合适就继续重复。而 denite 利用 `-auto-action=preview` 选项，配合 colorscheme source，可以方便的切换主题。

```vim
:Denite -auto-action=preview colorscheme`
```

`-auto-action=preview` 的意思是，对选中的结果，自动执行 preivew 的操作。`-auto-action` 是 denite 的 option。可以通过 `denite#custom#option` 设置自定义 option。默认设置下，`-auto-action` 是空的。

```vim
call denite#custom#option('default', 'auto_action', 'preview')
```

option 的名字需要改一下，去掉前缀的 `-` 并且把中间的 `-` 替换为 `_`。

## 我的配置

```vim
nnoremap <leader><space> :Denite<space>

call denite#custom#alias('source', 'file/rec/git', 'file/rec')
call denite#custom#var('file/rec/git', 'command', ['git', 'ls-files', '-co', '--exclude-standard'])
nnoremap <silent> <C-p> :<C-u>Denite -auto-action=preview 
            \ `finddir('.git', ';') != '' ? 'file/rec/git' : 'file/rec'`<cr>
nnoremap <leader>c :<C-u>Denite colorscheme -auto-action=preview<cr>
nnoremap <leader>; :<C-u>Denite file_mru<cr>

call denite#custom#map('insert', '<tab>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert', '<S-tab>', '<denite:move_to_previous_line>', 'noremap')
call denite#custom#map('insert', '<C-cr>', '<denite:choose_action>', 'noremap')
call denite#custom#map('insert', 'jj', '<denite:enter_mode:normal>', 'noremap')

call denite#custom#map('normal', '<tab>', '<denite:do_action:preview>', 'noremap')
call denite#custom#map('normal', '<S-tab>', '<denite:choose_action>', 'noremap')

call denite#custom#option('default', 'winheight', '15')
```

有两点说明下。其中 file/rec/git 相关，是 denite 的 FAQ 中的方案。因为默认情况下，file/rec 会显示所有目录下的文件，包括 .git 目录，直接用 file/rec 的结果并非期望的结果，所以当存在 .git 目录时，用 `git ls-files` 获取文案列表。配置中使用了一个 file_mru 的 source，提供的是最近使用的文件的列表，这个 source 不是 denite 内置的，是由插件 neomru 提供的，与 denite 是同一个作者 Shougo。

# 总结

denite 的配置难度比较高，但是配置好之后，用起来就非常顺手。另外，neovim 一个很重也好的发展方向，就是 embeded everywhere，也就是嵌入各种地方。给 neovim 套一个更现代的一个壳，是我对 neovim 的一个非常大的期待。而 denite 给现代的壳，提供了一个非常好的实现 Ctrl-P 的方式。

[neovim]: https://neovim.io
[Denite.nvim]: https://github.com/Shougo/denite.nvim
[fzf.vim]: https://github.com/junegunn/fzf.vim
[ctrlp.vim]: https://github.com/kien/ctrlp.vim

