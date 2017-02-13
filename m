From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 23:06:05 +0000 (UTC)
Subject: master - dmeventd: unify error handling
Message-ID: <20170213230605.CF43E606FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05dd566a52e4311c0626eb1a1250042aba746fae
Commit:        05dd566a52e4311c0626eb1a1250042aba746fae
Parent:        5a87d8667d0a8cadfea13f837cf01c91d86dad0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 13 19:00:59 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 14 00:03:34 2017 +0100

dmeventd: unify error handling

Always make sure the 'status' is release on 'error' path (thin pluging missed)
Make code looking same across all plugins.
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |   11 +++++------
 daemons/dmeventd/plugins/raid/dmeventd_raid.c      |    7 ++++---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    7 ++++---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    7 ++++---
 4 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 3d3a6de..4ec348f 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -184,16 +184,12 @@ int register_device(const char *device,
 		goto_bad;
 
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvscan, sizeof(state->cmd_lvscan),
-				   "lvscan --cache", device)) {
-		dmeventd_lvm2_exit_with_pool(state);
+				   "lvscan --cache", device))
 		goto_bad;
-	}
 
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
-				   "lvconvert --repair --use-policies", device)) {
-		dmeventd_lvm2_exit_with_pool(state);
+				   "lvconvert --repair --use-policies", device))
 		goto_bad;
-	}
 
 	*user = state;
 
@@ -203,6 +199,9 @@ int register_device(const char *device,
 bad:
 	log_error("Failed to monitor mirror %s.", device);
 
+	if (state)
+		dmeventd_lvm2_exit_with_pool(state);
+
 	return 0;
 }
 
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 911ae7a..ae3fc86 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -140,10 +140,8 @@ int register_device(const char *device,
 				   "lvscan --cache", device) ||
 	    !dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
 				   "lvconvert --config devices{ignore_suspended_devices=1} "
-				   "--repair --use-policies", device)) {
-		dmeventd_lvm2_exit_with_pool(state);
+				   "--repair --use-policies", device))
 		goto_bad;
-	}
 
 	*user = state;
 
@@ -153,6 +151,9 @@ int register_device(const char *device,
 bad:
 	log_error("Failed to monitor RAID %s.", device);
 
+	if (state)
+		dmeventd_lvm2_exit_with_pool(state);
+
 	return 0;
 }
 
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index a70d07c..bab7f0e 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -254,10 +254,8 @@ int register_device(const char *device,
 
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvextend,
 				   sizeof(state->cmd_lvextend),
-				   "lvextend --use-policies", device)) {
-		dmeventd_lvm2_exit_with_pool(state);
+				   "lvextend --use-policies", device))
 		goto_bad;
-	}
 
 	state->percent_check = CHECK_MINIMUM;
 	*user = state;
@@ -268,6 +266,9 @@ int register_device(const char *device,
 bad:
 	log_error("Failed to monitor snapshot %s.", device);
 
+	if (state)
+		dmeventd_lvm2_exit_with_pool(state);
+
 	return 0;
 }
 
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index e447ba2..e7d24c5 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -359,10 +359,8 @@ int register_device(const char *device,
 		goto_bad;
 
 	if (!dmeventd_lvm2_command(state->mem, cmd_str, sizeof(cmd_str),
-				   "_dmeventd_thin_command", device)) {
-		dmeventd_lvm2_exit_with_pool(state);
+				   "_dmeventd_thin_command", device))
 		goto_bad;
-	}
 
 	if (strncmp(cmd_str, "lvm ", 4) == 0) {
 		if (!(state->cmd_str = dm_pool_strdup(state->mem, cmd_str + 4))) {
@@ -401,6 +399,9 @@ inval:
 bad:
 	log_error("Failed to monitor thin pool %s.", device);
 
+	if (state)
+		dmeventd_lvm2_exit_with_pool(state);
+
 	return 0;
 }
 


