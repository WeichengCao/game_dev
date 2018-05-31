
# game_dev
***                                                                                                                                                                                     
基于skynet引擎的回合制游戏搭建

这里我们介绍的是一种单服的游戏服务器结构，即我们在一台物理机上只运行一个服务器进程，所有的游戏内容都运行在此进程中。
<br>影响服务器承载玩家上限主要有这么几点:
<br>1.机器性能：主要在机器的主频，内存，cpu缓存上
<br>2.网络问题：带宽，IO读写
<br>3.游戏代码结构设计：单进程单线程的设计，所有的事务都需要等待上一条事务执行完毕才能开始处理
<br>4.游戏逻辑代码实现：游戏逻辑代码实现中需要注意编程语言的性能问题，以及一些玩法开发的耗时注意事项

<br>基于skynet的开发，我们将我们的游戏结构设计成一个单进程多线程的结构，对于比较耗时的服务，如场景，战斗，
<br>广播等一些功能我们可以另多开几个服务<lua虚拟机>去专门做这些处理，分散线程的压力。在此份代码中，可以看
<br>到在service下回出现war/scene/broadcast 等目录；这就是针对上述说表的具体实现

## 1.游戏代码目录结构
game_dev

	-shell			存放常用的shell指令，如开关服务器，同步代码逻辑等

	-log			服务器输出内容

	-service		游戏逻辑内容
		
		-world		游戏主逻辑服务
		-login		游戏登陆逻辑
		-war		游戏战斗逻辑、
		-scene		游戏场景逻辑
		-broadcast	游戏广播逻辑
		-gamedb		游戏存盘逻辑
	
	-config			游戏相关配置信息

	-tools			游戏辅助工具，如模拟客户端，压测脚本，机器人

	-lualib			各个服务公共代码

	-proto			协议文件
	
	-skynet			游戏引擎相关

    
## 2.skynet引擎搭建
a.使用git检出一份skynet源码， 检出地址为：https://github.com/cloudwu/skynet.git， 我检出的版本为：c91efa513435e71f24fd869e15ef409e0caf6c86

b.在skynet目录下，编译源码，期间会遇到一些库文件确实问题， 安装后再进行编译即可

c.编译完成后,在skynet下我们会看到一份skynet/skynet的执行文件，skynet的启动流程可以通过追踪skynet-src/skynet_main.c进行了解，在这里不在做具体的阐述。游戏的启动脚本我把他放在了shell/gs_run.sh脚本下，通过执行该脚本我们可以将游戏服务器运行起来，当然你得先配置好config/gs_config.lua文件，通过配置我们可以知道最终的启动工具是通过snlua bootstrap启动bootstrap，然后通过bootstrap启动gs_launcher，gs_launcher.lua去启动游戏逻辑中需要的各项服务内容

## 3.游戏后台搭建
之前经历过的项目，大多都是在游戏的聊天窗口开放gm权限，通过输入指定格式的指令进行gm操作。 在该框架中，我们提供了一套另外的游戏后台，在这套框架中称之为dictator; dictator主要实现的是后台指令，区别游戏中的gm指令,dictator主要用来实现在线更新,是否开放玩家登陆,关闭存盘等相关指令;每个服务的启动都会向该服务注册一份各服务的地址信息，dictator做为一个指令的发起方，将指令根据地址传送到各个服务上；根据这个机制可以实现各个服务代码的在线更新，启动这个服务后，我们会监听本机器上的dictator_port端口(在config/gs_config.lua中配置)，通过

`nc localhost dictator_port`

可以直连上后台，就可以输入相关的指令进行相关操作，如在线更新指令

`update_code service/world/dictatorobj`

与此同时，我们还启动了debug_console后台（skynet内置），用于监控各个服务的状态，相应代码位于 skynet/service/debug_console.lua下；

## 4.lua代码文件在线更新
参照云风博客：https://blog.codingnow.com/2008/03/hot_update.html

在这个系统中，载入一个文件我们使用了两种方式，一个是系统自带的require，另外一个是自己实现的import；代码位于lualib/base/reload.lua下，这种划分相当于把文件按照能否在线更新作为了标准；使用require的，我们默认认为此文件不能进行在线更新，使用import则是可以使用lualib/base/reload.lua 下的reload文件进行在线更新

在原生lua环境下，我们引用一个文件通常使用require，使用require后我们会把内容放置到package.loaded下，而package.loaded有缓存机制， lua会组织加载同名称的模块，如果我们要更新这个文件，首先我们会把package.loaded置空，然后重新require一次，但是这种写法会使得一些地方无法更新到 如：local mod = require "module"; 就算你重新require了一次，这里的引用关系保持的还是旧的，除非我们把所有引用关系都遍历更新一次。而这个在线更新机制在不解除旧有引用关系的前提下对内部数据进行了替换，详细实现参照代码：

lualib/base/reload.lua

在上述文件实现的方法中，并不支持对upvalue的在线更新， 因为在我看来，要正确的实现所有upvalue的更新比较困难， 因为我更倾向于在代码的实现过程中加上一些限制，具体如在实现闭包的过程中，我们不在闭包中实现具体的函数，而是执行外部函数的一个调用，闭包函数只负责传递参数。

不适用

    function rpc_request(args, callback)
		callback(args)
	end
	
	rpc_request(args, function(args)
		dosomething1
		dosomething2
		dosomething3
	end)

	
而是

    rpc_request(args, function(args)
		rpc_callback(args)
	end)

	function rpc_callback(args)
		dosomething1
		dosomething2
		dosomething3
	end


## 5.关于多服务数据共享(sharedata)

在skynet中有一个叫做sharedatad的全局服务, 代码路径：skynet/lualib/sharedata.lua支持new|query|update 三种方法；sharedata.new(name, v, ...) 通过此方法可以创建一个新的sharedata数据块，v可以是字符串，table； sharedata.query(name) 通过此方法可以获得已经创建的sharedata数据块，但是我们发现实际每一次query都会去创建一次新的table，实际上我们可以在上层的使用方法上去规避他sharedata.update(name, v) 可以将名字为name的sharedata使用v进行一次更新

同时，在我的设想中，这个框架对于sharedata的数据应用应该只停留在读取游戏中的配置数据，一般来讲是导表数据，并且只提供读不提供写， 我们不会去也不应该去改写sharedata上的数据，有数据需要需要变动的时候，我们通过在线调用update的方式去更新这些数据。由上述分析可以知道，我们要实现这写功能，需要有一个专门的服务去启动sharedatad和在线更新sharedata同时还需要有个文件去做数据加载的功能，需要对query做一层封装，规避重复创建table问题, 同时重写__newindex方法把sharedata设置为只读

## 6.关于数据存储
在这套框架中，我们的数据库采用mongodb；没有特别的原因，只是刚好我在使用这个数据库而已，想要使用mysql也是可以的。skynet也提供了mysql的lua接口，在使用mongodb的时候要注意规避内存OOM的问题，因为mongodb引擎采用的是内存换效率的策略，如果不加已限制，则会导致机器的内存被完全耗尽。skynet 封装了一套mongodb的lua接口，位于skynet/lualib/mongo.lua；这个框架的所有存储实现都基于这个模块去做的实现。

根据skyent的单进程多线程模型，我们对整个游戏启动了一个专门处理数据存储的服务（或者多个），叫做gamedb。 在gamedb中，我们实现了一套适用于游戏存储的一套方法，位于：service/gamedb/gamedb.lua下其他服务如果有存储的需求，将需要存储的数据发送到gamedb服务下，去做存储有效的去分担主线程的压力。 （如果我们开启的是多个gamedb服务， 一定要保证一个数据源只会被一个gamedb改动。）

在这套回合制游戏框架中，我们的存盘策略采用的是相对来说比较简单的策略，目前的想法只涉及到

	[定时存盘]：对于容错率相对来说比较高的数据块，我们采用打脏标记，5分钟一次的存盘策略
	[及时存盘]：对于容错率低的数据块，则我们采用的是即时存盘，比如玩家的ID分配等一些相关内容
	[关联存盘]：对于数据关联性比较大的多个块，我们采用关联存盘，就算回档也会回到同一时间段，比如玩家之间的交易行为

## 7.跨服务数据交互

在[5]中我们提到了要对共享数据进行在线更新，而共享数据也是单独的一个服务，我们怎么做到在dictator后台对sharedatad服务的数据进行更新？在[6]中我们也提到了gamedb用于存储逻辑服务产生的存盘数据，但是我们怎么将存盘块数据发送到gamedb中进行存储，需要的使用我们又怎么从gamedb中获取到相关数据。这就是我们需要做跨服务数据交互通讯的理由。

在skynet中，我们每启动一个服务都会有个专门的标识，在log/gs.log中我们可以看到一串的十六进制字符，这个其实就是每个服务的一个标识符，也可以说是每个服务的地址，我们通过这个地址在整个进程中找到这个服务，与此同时我们在每启动一个服务的时候也会向skynet注册一个服务的别名。如在启动gamedb的时候，我们有skynet.register(".gamedb")，只要注册了这个别名，我们也可以通过该别名去访问相应的服务

在interactive中我们定义了另外通信协议PTYPE_LOGIC，（ACTOR模型支持每个actor定制自己的通信行为） 专门用于游戏逻辑服务间的通讯，在每个服务启动的时候我们需要调用interactive.dispatch_logic进行一次初始化具体的代码实现在lualib/base/interactive.lua下。为什么要从写一份interactive，而不是直接使用skynet.call这个现成的rpc模型， 主要是因为从我的角度来说，skynet.call的实现太像一个同步的过程了，而实际上是一个异步的处理，使用不当容易造成问题； 在interactive中我们对skynet.send接口进行了封装，实现了游戏内使用的send和request， 具有显示的异步性质，同时也不需要我们去考虑是各个服务是采用了哪套具体的通信协议，只要指定模块和函数名就可以。

## 8.客户端服务端协议交互(protobuf)

客服务端之间的通讯我们引入protobuf，协议的解析我们采用云风写的pbc。首先我们需要在机器上安装一个protobuf，我采用的是直接检出git安装的，git地址：

	git clone https://github.com/google/protobuf.git

在运行./autogen.sh 之前，我们还需要安装一些必要的内容，有unzip,autoconf,automake,libtool

	1.执行 ./autogen.sh

	2.执行 ./configure 执行过程中可能会遇到一些问题，通常是库缺失，自行安装即可

	3.make

	4.make check

	5.make install


编译pbc的时候采用了一种比较取巧的方式，直接将pbc， https://github.com/cloudwu/pbc.git 下中我们所需要的文件放入到skynet下的pbc文件夹下，有makefile，src，pbc.h，将pbc/binding下的pbc-lua53放到pbc下，然后通过改写skynet/Makefile文件直接进行编译导入,最终，我们的使用方式和pbc/binding下介绍的一致,只是我们将protobuff.lua文件放到了game_dev/lualib/base下,这样我们就可以直接require "base.protobuf" 使用它

在这个游戏框架中，我将协议放到了proto/下， proto/base.proto 用于放置各个协议通用数据结构，proto/server/x.proto 下放置的是服务端下行协议，统一命名方式是GS2CXXXX， proto/client/x.proto 下放置的是客户端上行协议,统一命名方式是C2GSXXXX。通过shell/make_proto.sh
进行协议的编译，编译结果为proto/proto.pb文件

在游戏启动的时候，我们通过在lualib/base/preload中调用了netfind.Init进行了协议的初始化, 这样我们就可以在游戏中使用protobuf.encode protobuf.decode进行协议的编码，解码操作。

proto/netdefines.lua 的作用是定义了各个交互协议的协议号，我们在客服务端交互的时候需要将每个协议的协议号打包进数据流，客户端和服务端使用同一套标准，在收包的时候通过解指定协议号得到协议名，然后可以使用protobuf.decode 进行相关解析操作，最终得到我们发送的数据, 相关内容位于：lualib/base/net.lua 和 lualib/base/netfind.lua 两个文件下

## 9.收发包流程 以及模拟客户端操作

服务端在收到客户端模拟建立连接的时候, gate收到请求会生成一个固定格式的字符串并用PTYPE_TEXT格式将msg发送给给注册进行来的watch_dog; 详见：skynet/service-src/service_gate.c的_report函数。watch_dog 收到消息后可以解析出 ip，端口，fd等相关信息，并对这些信息进行保留，用以回发数据,skynet 也支持了对协议处理设置代理，让协议数据的处理转发到另外的服务中去处理。我们在设置好代理并建立了连接后，就可以开始了通信。目前我写了一个简单的交互例子，服务端代码位于service/login下， 客户端代码位于tool/下；在服务器已经正常运行的状态下执行

	./shell/client.sh -s client_script/login.lua -a account


## 10.关于baseobj的计时器

游戏服务器中常用的计时器功能直接封装了skynet.timeout函数，提供了三个接口供游戏使用，分别是：AddTimeCb：用于添加计时器，DelTimeCb：删除计时器，GetTimeCb：获取计时器，通过这三个接口可以灵活的实现游戏逻辑功能。代码实现看lualib/base/timer.lua

在skyent的计时器中，我们将计时的时间分为了5个段， 32位的int按照（6，6，6，6，8）这样的方式将时间由远及近分为了5个段，这同时要求我们不能进行过大的计时器调用， 在游戏中我们也一般不会进行过大的计时调用。


## 11.关于存盘

游戏服务器中的存盘在没有特殊情况下，由各个对象自行实现存盘即可， 但是对于游戏中的对象而言，难免会碰到需要关联存盘的情况；如果，两个玩家之间进行交易，这时候会对两个玩家对象的数据打脏，如果是分开存盘的话，在服务器宕机的时候，如果一个玩家的数据存盘了，另外一个玩家的数据没有存盘， 这个时候再启动服务器的话，就会出现两边数据不同步的情况。savemgr在这里做的关联存盘就是为了大概率的避免这种情况，要回档一起回档，要存盘一起存盘；这样到时候通过查询log也好做补偿。 尽最大的可能保证数据的一致性。

## 12.登陆系统

登陆系统使用的是的一个账号对应多个角色，模拟客户端脚本位于/tools/client_script/login.lua脚本下，客户端发送账号登陆协议过来，服务器在数据库中查找玩家已经生成的角色，返回给客户端，玩家自行决定是否创建角色或者直接选中角色登陆，我们在之前的服务基础上多开启了一个id分配的服务也可以开启另外一台中心功能服，用于处理id分配等功能。玩家拿到id后尝试插入数据到player表中，player表中在游戏数据库初始化的时候就建立了pid和name的唯一索引，如果插入不成功，我们可以认为玩家名字或者玩家id出现了重复的情况，给予开发人员一个警报。如果成功后则在登陆后可以通过pid对player的信息进行完善。玩家完成数据加载等一些列登陆过程后，服务器下行一条登陆完成协议给客户端，客户端通过该协议做相应的处理，并建立于服务器的心跳机制。客户端断开socket后，我们不直接卸载玩家对象，在内存中保存玩家对象一段时间，时间长短自定义。超过时间未登陆则卸载玩家对象。模拟登陆指令：

	`./tools/client.sh -s ./tools/client_script/login.lua -a test_acount`


## 13.玩家模块

在这个框架中，我们将玩家的数据分为了在线数据和离线数据；顾名思义，在线数据就是玩家在线的时候才会加载出来的数据，离线数据则是玩家不在线的时候也可以通过其他方法加载出来的数据，比如玩家的充值数据，玩家的战斗数据（用于玩家镜像战斗）；对于玩家的在线数据，我们又划分出了一系列子模块，常涉及到的有玩家基本属性，玩家道具,玩家任务，玩家宠物，玩家技能，玩家装备，玩家带时效性变量等一些列模块；不一一列举，只做部分示例。对于玩家离线数据，我们划分为离线基本信息模块，包含了玩家基础属性信息，玩家战斗数据模块等；以适用于游戏玩法。

基础属性模块:用于保存玩家基础属性中不常变动的信息，例如玩家的名字，玩家头像，玩家造型玩家性别等，保证此模块存盘的低频。

活跃属性模块:用于保存玩家基础属性中变动频率较高的信息，如玩家等级，玩家经验等属性。


## 14.玩家属性刷新机制

在以往的工作经验中，我经常会碰到这样一种情况：一个玩家获得经验后，如果触发玩家的升级，则会触发以下一系列操作：增加玩家经验，检查经验是否满足升级条件，满足的话，扣除升级所需要经验，玩家等级+1，计算因为等级变动而变动的属性，例如血量，法力值等；以上这些变动我们都需要通过协议刷新给客户端。按照以往的做法就是一种属性变动触发一条协议刷新，或者就是进行一次全量刷新；根据上面的例子就是获得经验刷新一次经验数据给客户端，升级扣经验则再刷一次经验和等级数据给客户端，再触发其他属性变动，则根据属性值进行刷新，或者进行一次全属性刷新，这样就会造成了大量的资源浪费。在这个框架中，我们对触发的数据变动做了一个临时缓存，在一个skynet.dispatch_message执行完后，执行一次属性刷新，对刷新的属性生成一份掩码，这样可以保证发刷新的属性只是有变动的值，客户端根据掩码解析出的协议值就是本次刷新内容（充分利用的protobuff的特性）。代码实现可追踪lualib/base/hook.lua 查看