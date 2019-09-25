From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Wed, 25 Sep 2019 13:53:50 +0200
Subject: stable-2.02 - libdaemon: fix the race of handling SIGTERM timeout
In-Reply-To: <723608783F175343AAB90DD84928BC3401196923@dggeml510-mbx.china.huawei.com>
References: <723608783F175343AAB90DD84928BC3401196923@dggeml510-mbx.china.huawei.com>
Message-ID: <3f461031-fcd7-1fe4-5abf-de5d9b7e8225@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25. 09. 19 v 9:48 wangjufeng napsal(a):
>  From e97d3a14d070a85867ce39fc1749d19c2ac0b685 Mon Sep 17 00:00:00 2001
> 
> From: wangjufeng <wangjufeng@huawei.com>
> 
> Date: Wed, 25 Sep 2019 15:34:25 +0800
> 
> Subject: [PATCH] libdaemon: fix the race of handling SIGTERM timeout
> 
> When the daemon service lvmetad running without "-t" option,system
> 
> shutdown may take a long time.
> 
> error could be simulated follow those steps:
> 
> 1.remove "-t" option from lvmetad start arguments.
> 
> 2.start a process p1 like this
> 
>  ??????????????? while :
> 
>  ??????????????? do
> 
>  ??????????????????????????????? time service lvm2-lvmetad stop
> 
>  ??????????????????????????????? sleep 2
> 
>  ??????????????????????????????? service lvm2-lvmetad start
> 
>  ??????????????? done
> 
> 3.start a process p2 like this
> 
>  ??????????????? while :
> 
>  ??????????????? do
> 
>  ??????????????????????????????? lvs
> 
>  ??????????????? done
> 
> 4.use ctrl+c stop process p2, it is very easy to occur that, stop
> 
> lvm2-lvmetad timeout.
> 
> This is because, when system shutdown, lvmetad recieve SIGTERM,
> 
> _shutdown_requested will change to 1 asynchronously. If a client
> 
> thread is still running, s.threads->next is not NULL. It could
> 
> happen that (_shutdown_requested && !s.threads->next) will not be
> 
> satisfied before calling pselect, then it call pselect and get
> 
> blocked . If no new request or signall come, systemd have to
> 
> send SIGKILL after SIGTERM timeout, usually it could take 90
> 
> seconds.
> 
> This patch call _reap(s, 1) to finish all client threads after
> 
> _shutdown_requested change to 1. And always pass a timeout
> 
> value to pselect to avoid that _shutdown_requested change to 1
> 
> between judging _shutdown_requested value and calling pselect.
> 
>


Hi


Can you please check out the attached patch that simply disallows accepting 
new connections while 'shutdown' is requested ?

Your example is in fact not the case we intended to support  - if there *IS* a 
running user - we shall serve it - instead of killing lvmetad in the middle of 
lvm2 command.

So all served clients should be finished (and lvmetad should be 'quick' at 
this serving - as all it does is to stream some cached data to socked.

But - we likely should not accept any new connection when we know we are going 
to 'shutdown' - which is what my proposal patch is doing  - otherwise we are 
in danger that user running 'endless' loop of lvs will prevent shutdown.

The next issue is - WHY is your shutdown sequence using any lvm commnand when 
lvmetad service is being stopped ??  This looks like a logical issue in 
shutdown sequence?


Regards

Zdenek
-------------- next part --------------
A non-text attachment was scrubbed...
Name: patch.diff
Type: text/x-patch
Size: 808 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190925/9c51da06/attachment.bin>
