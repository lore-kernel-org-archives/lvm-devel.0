From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:22 +0000 (UTC)
Subject: master - dmeventd: add local mempool for raid and mirror
Message-ID: <20151013140422.2F5BF6073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49e11102c78ddf74bead6020fc51cae0e78e2ad2
Commit:        49e11102c78ddf74bead6020fc51cae0e78e2ad2
Parent:        a11cd2ca2d4edbf16c61f8066b1f745fa2fe7d4b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 11:28:57 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:56:23 2015 +0200

dmeventd: add local mempool for raid and mirror

Using local mempools allows to drop locks when such memory is needed.
---
 WHATS_NEW_DM                                      |    1 +
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |   35 +++++++++++++++++++--
 daemons/dmeventd/plugins/raid/dmeventd_raid.c     |   32 +++++++++++++++++--
 3 files changed, 62 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f041ed1..902a485 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Use local mempool for raid and mirror plugins.
   Reworked thread initialization for dmeventd plugins.
   Dmeventd handles snapshot overflow for now equally as invalid.
   Convert dmeventd to use common logging macro system from libdm.
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index d418b08..e8761d9 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -23,6 +23,12 @@
 #define ME_INSYNC    1
 #define ME_FAILURE   2
 
+struct dso_state {
+	struct dm_pool *mem;
+	char cmd_lvscan[512];
+	char cmd_lvconvert[512];
+};
+
 DM_EVENT_LOG_FN("mirr")
 
 static int _process_status_code(const char status_code, const char *dev_name,
@@ -217,12 +223,33 @@ int register_device(const char *device,
 		    int minor __attribute__((unused)),
 		    void **user)
 {
-	if (!dmeventd_lvm2_init())
-		return 0;
+	struct dso_state *state;
+
+	if (!dmeventd_lvm2_init_with_pool("mirror_state", state))
+		goto_bad;
+
+	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvscan, sizeof(state->cmd_lvscan),
+				   "lvscan --cache", device)) {
+		dmeventd_lvm2_exit_with_pool(state);
+		goto_bad;
+	}
+
+	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
+				   "lvconvert --config devices{ignore_suspended_devices=1} "
+				   "--repair --use-policies", device)) {
+		dmeventd_lvm2_exit_with_pool(state);
+		goto_bad;
+	}
+
+	*user = state;
 
 	log_info("Monitoring mirror device %s for events.", device);
 
 	return 1;
+bad:
+	log_error("Failed to monitor mirror %s.", device);
+
+	return 0;
 }
 
 int unregister_device(const char *device,
@@ -231,9 +258,11 @@ int unregister_device(const char *device,
 		      int minor __attribute__((unused)),
 		      void **user)
 {
+	struct dso_state *state = *user;
+
+	dmeventd_lvm2_exit_with_pool(state);
 	log_info("No longer monitoring mirror device %s for events.",
 		 device);
-	dmeventd_lvm2_exit();
 
 	return 1;
 }
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 6522556..714832b 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -16,6 +16,13 @@
 #include "dmeventd_lvm.h"
 #include "libdevmapper-event.h"
 
+struct dso_state {
+	struct dm_pool *mem;
+	char cmd_lvscan[512];
+	char cmd_lvconvert[512];
+	int failed;
+};
+
 DM_EVENT_LOG_FN("raid")
 
 /* FIXME Reformat to 80 char lines. */
@@ -154,12 +161,29 @@ int register_device(const char *device,
 		    int minor __attribute__((unused)),
 		    void **user)
 {
-	if (!dmeventd_lvm2_init())
-		return 0;
+	struct dso_state *state;
+
+	if (!dmeventd_lvm2_init_with_pool("raid_state", state))
+		goto_bad;
+
+	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvscan, sizeof(state->cmd_lvscan),
+				   "lvscan --cache", device) ||
+	    !dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
+				   "lvconvert --config devices{ignore_suspended_devices=1} "
+				   "--repair --use-policies", device)) {
+		dmeventd_lvm2_exit_with_pool(state);
+		goto_bad;
+	}
+
+	*user = state;
 
 	log_info("Monitoring RAID device %s for events.", device);
 
 	return 1;
+bad:
+	log_error("Failed to monitor RAID %s.", device);
+
+	return 0;
 }
 
 int unregister_device(const char *device,
@@ -168,9 +192,11 @@ int unregister_device(const char *device,
 		      int minor __attribute__((unused)),
 		      void **user)
 {
+	struct dso_state *state = *user;
+
+	dmeventd_lvm2_exit_with_pool(state);
 	log_info("No longer monitoring RAID device %s for events.",
 		 device);
-	dmeventd_lvm2_exit();
 
 	return 1;
 }


