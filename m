From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:29 +0000 (UTC)
Subject: master - cleanup: dmeventd abstract lvm2cmd interface
Message-ID: <20140418145529.6DEDA6109E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b701c3a48aede064850f7b3d16021d60fa8e541
Commit:        6b701c3a48aede064850f7b3d16021d60fa8e541
Parent:        6448428d05f53a478a892b9792d22407d10c1464
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 15 23:11:03 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:51 2014 +0200

cleanup: dmeventd abstract lvm2cmd interface

Keep  lvm2cmd  interface hidden inside dmeventd_lvm
and use regular 1/0 return codes, this we may
avoid using lvm2cmd.h in other lvm2 plugins.
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c       |    2 +-
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |    5 ++---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c      |    5 ++---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    3 +--
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    3 +--
 5 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 6d2c3de..80ed83a 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -143,7 +143,7 @@ struct dm_pool *dmeventd_lvm2_pool(void)
 
 int dmeventd_lvm2_run(const char *cmdline)
 {
-	return lvm2_run(_lvm_handle, cmdline);
+	return (lvm2_run(_lvm_handle, cmdline) == LVM2_COMMAND_SUCCEEDED);
 }
 
 int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 864f0e2..2328089 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -14,7 +14,6 @@
 
 #include "lib.h"
 
-#include "lvm2cmd.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 #include "defaults.h"
@@ -144,9 +143,9 @@ static int _remove_failed_devices(const char *device)
 	r = dmeventd_lvm2_run(cmd_str);
 
 	syslog(LOG_INFO, "Repair of mirrored device %s %s.", device,
-	       (r == LVM2_COMMAND_SUCCEEDED) ? "finished successfully" : "failed");
+	       (r) ? "finished successfully" : "failed");
 
-	return (r == LVM2_COMMAND_SUCCEEDED) ? 0 : -1;
+	return (r) ? 0 : -1;
 }
 
 void process_event(struct dm_task *dmt,
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 9da2e7c..3fbae15 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -14,7 +14,6 @@
 
 #include "lib.h"
 
-#include "lvm2cmd.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
@@ -40,10 +39,10 @@ static int run_repair(const char *device)
 
 	r = dmeventd_lvm2_run(cmd_str);
 
-	if (r != LVM2_COMMAND_SUCCEEDED)
+	if (!r)
 		syslog(LOG_INFO, "Repair of RAID device %s failed.", device);
 
-	return (r == LVM2_COMMAND_SUCCEEDED) ? 0 : -1;
+	return (r) ? 0 : -1;
 }
 
 static int _process_raid_event(char *params, const char *device)
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index bbee93a..1b1d977 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -14,7 +14,6 @@
 
 #include "lib.h"
 
-#include "lvm2cmd.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
@@ -82,7 +81,7 @@ static int _run(const char *cmd, ...)
 
 static int _extend(const char *cmd)
 {
-	return dmeventd_lvm2_run(cmd) == LVM2_COMMAND_SUCCEEDED;
+	return dmeventd_lvm2_run(cmd);
 }
 
 static void _umount(const char *device, int major, int minor)
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index f0d3f24..3f057a6 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -14,7 +14,6 @@
 
 #include "lib.h"
 
-#include "lvm2cmd.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
@@ -147,7 +146,7 @@ static int _extend(struct dso_state *state)
 #if THIN_DEBUG
 	syslog(LOG_INFO, "dmeventd executes: %s.\n", state->cmd_str);
 #endif
-	return (dmeventd_lvm2_run(state->cmd_str) == LVM2_COMMAND_SUCCEEDED);
+	return dmeventd_lvm2_run(state->cmd_str);
 }
 
 static int _run(const char *cmd, ...)


