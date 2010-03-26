From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 25 Mar 2010 22:59:07 -0400
Subject: [PATCH] allow disabled dmeventd monitoring to propagate via clvmd
In-Reply-To: <20100325215100.GA27929@redhat.com>
References: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
	<4BA9D905.9090107@redhat.com> <20100324130736.GA19258@redhat.com>
	<20100324154359.GA845@redhat.com>
	<20100325215100.GA27929@redhat.com>
Message-ID: <20100326025907.GA17663@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The lvm commands that control dmeventd monitoring (lvchange, vgchange,
lvcreate) now properly establish the '_dmeventd_monitor' via commandline
of lvm.conf -- they in turn pass their setting on to clvmd through
_lock_for_cluster().

So we really don't have a need to init_dmeventd_monitor() based on
lvm.conf when creating or refreshing the toolcontext -- especially not
for clvmd's benefit.

And all existing dmeventd_monitor_mode() callers properly account for it
returning tri-state (except for _lock_for_cluster() -- it treating it as
a binary return didn't dawn on me until I wasted too much time tracing
this issue).

I've tested this minimalist patch quite a bit:


clvmd's do_lock_lv() already properly controls dmeventd monitoring based
on LCK_DMEVENTD_MONITOR_MODE in lock_flags -- though one small fix was
needed for this to work: _lock_for_cluster() must treat
dmeventd_monitor_mode()'s return as a tri-state value.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index b82b077..f98f445 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -307,6 +307,7 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 	char *args;
 	const char *node = "";
 	int len;
+	int dmeventd_mode;
 	int saved_errno = errno;
 	lvm_response_t *response = NULL;
 	int num_responses;
@@ -324,7 +325,8 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 	if (mirror_in_sync())
 		args[1] |= LCK_MIRROR_NOSYNC_MODE;
 
-	if (dmeventd_monitor_mode())
+	dmeventd_mode = dmeventd_monitor_mode();
+	if (dmeventd_mode != DMEVENTD_MONITOR_IGNORE && dmeventd_mode)
 		args[1] |= LCK_DMEVENTD_MONITOR_MODE;
 
 	if (cmd->partial_activation)


