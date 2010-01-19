From: Milan Broz <mbroz@redhat.com>
Date: Tue, 19 Jan 2010 13:23:45 +0100
Subject: [PATCH] Never scan suspended devices in clvmd.
Message-ID: <1263903825-907-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For mirror repair (and similar tasks) it can happen that full
device rescan is issued from clvmd.

Because code can be in the middle of repair (calling suspend)
clvmd should never try to scan suspended devices
(otherwise it causes deadlock).

Also code must not change ignore_suspended_device flag when
doing refresh_filters (called from lvmcache scan code).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    5 +++++
 lib/commands/toolcontext.c    |   11 ++++++++++-
 2 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index afe93e2..74c660e 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -499,6 +499,9 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 
 	cmd->partial_activation = (lock_flags & LCK_PARTIAL_MODE) ? 1 : 0;
 
+	/* clvmd should never try to read suspended device */
+	init_ignore_suspended_devices(1);
+
 	switch (command & LCK_MASK) {
 	case LCK_LV_EXCLUSIVE:
 		status = do_activate_lv(resource, lock_flags, LKM_EXMODE);
@@ -627,6 +630,7 @@ int do_refresh_cache()
 	}
 
 	init_full_scan_done(0);
+	init_ignore_suspended_devices(1);
 	lvmcache_label_scan(cmd, 2);
 	dm_pool_empty(cmd->mem);
 
@@ -860,6 +864,7 @@ int init_lvm(int using_gulm)
 
 	/* Check lvm.conf is setup for cluster-LVM */
 	check_config();
+	init_ignore_suspended_devices(1);
 
 	/* Remove any non-LV locks that may have been left around */
 	if (using_gulm)
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a076e93..99db7d0 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1231,12 +1231,21 @@ skip_dlclose:
 
 int refresh_filters(struct cmd_context *cmd)
 {
+	int r, saved_ignore_suspended_devices = ignore_suspended_devices();
+
 	if (cmd->filter) {
 		cmd->filter->destroy(cmd->filter);
 		cmd->filter = NULL;
 	}
 
-	return _init_filters(cmd, 0);
+	r = _init_filters(cmd, 0);
+
+	/*
+	 * During repair code must not reset suspended flag.
+	 */
+	init_ignore_suspended_devices(saved_ignore_suspended_devices);
+
+	return r;
 }
 
 int refresh_toolcontext(struct cmd_context *cmd)
-- 
1.6.6


