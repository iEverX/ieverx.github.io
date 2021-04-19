+++
title = "在 wsl 里运行 Intellij Idea"
date = 2021-04-20T23:05:59+08:00

draft = false

[taxonomies]
tags = ["wsl","Intelij Idea"]
+++

自从 wsl2 出来之后，就一直想把一些开发环境挪到 wsl 里，但是颇有波折。Intellij Idea 对于 wsl 的支持不太好，直到 2021.1，才比较好的支持打开 wsl 中的项目。不过问题还是比较多

- pom文件的编辑非常卡，即使尝试设置 IDE 使用 wsl 里的 maven，repository 以及 settings.xml 都是用 wsl 里的配置，依然很卡
- 下载依赖也比较慢
- 在 wsl 的根目录下会生成一个文件夹 `C:`，cd 进去，是一个 `AppData` 路径，似乎是 Intellij Idea 在 wsl 的 home 目录下，按照 Windows 的路径创建一些文件

本身 wsl 访问 Windows 文件是比较慢的，在第一次尝试的时候就是因为直接访问了 /mnt/c/ 目录下的 maven 仓库，导致索引慢得发指，这一次完全使用了 wsl 的路径，仍然是很慢。不太清楚是不是 Intellij Idea 的问题。

相比之下，使用 vscode 在 wsl 里开发的体验就好了很多，同时 vscode 还支持使用 container 的环境，比 Intellij Idea 高了不知到多少。然鹅，写 Java 断断是不能用vsocde 的。事情就这样的放下了，想着等啥时候 jetbrains 把这事情整明白了再说。直到某一天，看到 V2EX 上某个用户说，可以用 wsl 跑 gui，然后使用 linux 的 ide，一下子打开了一片天。

直接用「gui wsl」为关键词搜索，[第一篇][tutorial][^1]就是标准答案，按照过程一步步来，最后就OK了。文章里提到了3个 X server 软件，我只用了第一个 VcXsrv，其他两个并没有试，也不太需要。搞好之后，尝试 guid 应用时，直接下载 linux 版的 intellij 是最方便的，不用 apt 安装 gedit，因为安装 gedit 还挺费时间的，不如直接下载来得快。

我装好之后，使用上是没有问题的，但是ide的字体比较模糊，是由于高分辨率的问题导致的，可以参考[这篇文章][hdpi]。设置一下应用的模式，并且在 wsl 里设置`GDK_SCALE=2`环境变量，环境变量的作用[看这里][gdk]。这个文章里还提到了要设置`LIBGL_ALWAYS_INDIRECT=1`，不需要的，原因可以参考 [stackexchange 上的问题][stackexchange]。

ide 只能从 wsl 的命令行启动，第一次需要从程序目录下的 idea.sh 启动。启动后，ide 的 Tools -> Create Command Line Launcher 命令会创建一个可行执行程序，路径是 /usr/local/bin/idea，之后可以直接命令行敲 `idea` 启动。启动默认是前台，如果想要该，用 `idea &`启动，还想要要取消日志输出什么的，和普通的命令行程序没有区别，重定向就OK。不熟悉的看这个[链接][idea]，给了一整套机制。然鹅，即使使用 nohup 启动，进程是绑定到一个会话的，我通常是用 microsoft terminal，打开 idea 的 tab 一旦关闭，ide 也会随之关上。解决方案就是 tmux，关于 tmux 就不在本文多说了，文章很多很多了，而且我也不熟:rofl:


参考：
- <https://techcommunity.microsoft.com/t5/windows-dev-appconsult/running-wsl-gui-apps-on-windows-10/ba-p/1493242>
- <https://egoist.moe/wsl2-gui>

[tutorial]: https://techcommunity.microsoft.com/t5/windows-dev-appconsult/running-wsl-gui-apps-on-windows-10/ba-p/1493242
[stackexchange]: https://unix.stackexchange.com/questions/1437/what-does-libgl-always-indirect-1-actually-do
[hdpi]: https://egoist.moe/wsl2-gui
[gdk]: https://wiki.archlinux.org/index.php/HiDPI_(简体中文)#GDK_3_(GTK+_3)
[idea]: https://unix.stackexchange.com/questions/302164/how-to-run-intellj-idea-from-current-directory