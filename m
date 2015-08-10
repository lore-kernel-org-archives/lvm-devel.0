From: Ferenc Wagner <wferi@niif.hu>
Date: Mon, 10 Aug 2015 09:06:48 +0200
Subject: [PATCH 0/6] cmirrord memory handling fixes
In-Reply-To: <1436359287-6682-1-git-send-email-wferi@niif.hu> ("Ferenc
	=?utf-8?Q?W=C3=A1gner=22's?= message of "Wed,
	8 Jul 2015 14:41:21 +0200")
References: <1436359287-6682-1-git-send-email-wferi@niif.hu>
Message-ID: <87vbcn39mf.fsf@lant.ki.iif.hu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Ferenc W?gner <wferi@niif.hu> writes:

> During clustered pvmove tests cmirrord kept on dying.  To ease
> debugging, I added a --foreground option to it [1-3], which made the
> GCC stack protector messages stand out at once.  The backtraces made
> the fix straightforward [4].  As log_checkpoint seems a constant false
> condition, preparing the message is generally wasted effort, but I
> didn't want to change the logic, and now it does not crash the process
> at least.  Looking for other unsafe sprintf() usages provided plentiful
> results, I fixed the two easy ones [5,6].  Please use as you see fit.
>
> Ferenc W?gner (6):
>   cmirrord: move generic setup from daemonize() to init_all()
>   cmirrord: introduce the --foreground option to avoid daemonization
>   cmirrord: document the --foreground and --help options
>   cmirrord: fix stack smashing
>   cmirrord: avoid debugging buffer overflow in LOG_SPRINT
>   cmirrord: avoid resync buffer overflow in LOG_SPRINT
>
>  daemons/cmirrord/clogd.c     |   62 +++++++++++++++++++++++++++++++++---------
>  daemons/cmirrord/cluster.c   |   23 ++++++++++++----
>  daemons/cmirrord/functions.c |    5 ++--
>  man/cmirrord.8.in            |    8 +++++-
>  4 files changed, 76 insertions(+), 22 deletions(-)

Hi,

Are there any objections to these patches?  Shall I rework them to have
any hope for inclusion?
-- 
Thanks,
Feri.


