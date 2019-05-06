From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 6 May 2019 09:58:33 -0400
Subject: stable-2.02 - monitoring: fix monitoring change for cluster
Message-ID: <201905061358.x46DwXW7018217@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8921be641afe865c177e11b8859f4b937f76995
Commit:        a8921be641afe865c177e11b8859f4b937f76995
Parent:        9d7afaaab85404a562942f4662de8a2e7739d8fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 10 14:38:21 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 6 15:57:52 2019 +0200

monitoring: fix monitoring change for cluster

Fix bug in table reload for clustered VG.
Function used in lv/vgchange --monitor y|n is using 'somewhat' hackish
shortcut and accesses activation function monitor_dev_for_events()
directly rather through full device refresh to avoid table reload
in case user want to only change monitoring state of device.
However since with old 'mirrors' there is table change dropping
handle_error there was in some cases needed table update.

This was put into monitor_dev_for_events() with assumption
vg_write_lock_held() could be used to decide if the actual monitoring
change comes from read-only lock-holding commands lvchange/vgchange.
However the clustered locking part (clvmd) actually doesn't differentiate
about this concept of having VG openned in read-only or write mode.
So it caused unwanted reloads of mirror tables even in commands like lvconvert.

Thus for clustered locking there is full table reload put into the code and
shortcut applies only for non-clustered locking.

Also the patch tries to avoid calling repeated LV refresh in case the
lv/vgchange uses  --refresh & --monitor.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    4 ++--
 tools/lvchange.c        |   28 +++++++++++++++++++---------
 tools/vgchange.c        |   15 +++++++++++++--
 4 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4b73ccc..4b7be7c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.185 - 
 ==================================
+  Fix change of monitoring in clustered volumes.
   Improve -lXXX%VG modifier which improves cache segment estimation.
   Add synchronization with udev before removing cached devices.
   Fix missing growth of _pmsmare volume when extending _tmeta volume.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4c83231..dc9bc9e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2048,12 +2048,12 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		} else
 			continue;
 
-		if (!vg_write_lock_held() && lv_is_mirror(lv)) {
-			mirr_laopts.exclusive = lv_is_active_exclusive_locally(lv) ? 1 : 0;
+		if (!locking_is_clustered() && !vg_write_lock_held() && lv_is_mirror(lv)) {
 			/*
 			 * Commands vgchange and lvchange do use read-only lock when changing
 			 * monitoring (--monitor y|n). All other use cases hold 'write-lock'
 			 * so they skip this dm mirror table refreshing step.
+			 * Shortcut can't be applied with clustered locking.
 			 */
 			if (!_lv_activate_lv(lv, &mirr_laopts)) {
 				stack;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4195a80..7d0ec8f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -148,7 +148,8 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
  */
 
 static int _lvchange_monitoring(struct cmd_context *cmd,
-				struct logical_volume *lv)
+				struct logical_volume *lv,
+				int was_refreshed)
 {
 	struct lvinfo info;
 
@@ -163,8 +164,15 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
 			log_verbose("Monitoring LV %s", display_lvname(lv));
 		else
 			log_verbose("Unmonitoring LV %s", display_lvname(lv));
-		if (!monitor_dev_for_events(cmd, lv, 0, dmeventd_monitor_mode()))
-			return_0;
+
+		if (!was_refreshed) {
+			if (locking_is_clustered()) {
+				/* FIXME: doesn't work when the LV is not lockholder */
+				if ((lv == lv_lock_holder(lv)) && !lv_refresh(cmd, lv))
+					return_0;
+			} else if (!monitor_dev_for_events(cmd, lv, 0, dmeventd_monitor_mode()))
+				return_0;
+		}
 	}
 
 	return 1;
@@ -176,7 +184,8 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
  */
 
 static int _lvchange_background_polling(struct cmd_context *cmd,
-					struct logical_volume *lv)
+					struct logical_volume *lv,
+					int was_refreshed)
 {
 	struct lvinfo info;
 
@@ -187,7 +196,8 @@ static int _lvchange_background_polling(struct cmd_context *cmd,
 
 	if (background_polling()) {
 		log_verbose("Polling LV %s", display_lvname(lv));
-		lv_spawn_background_polling(cmd, lv);
+		if (!was_refreshed)
+			lv_spawn_background_polling(cmd, lv);
 	}
 
 	return 1;
@@ -1422,11 +1432,11 @@ static int _lvchange_refresh_single(struct cmd_context *cmd,
 	 * checking poll arg.  Pull that out of lv_refresh.
 	 */
 	if (arg_is_set(cmd, poll_ARG) &&
-	    !_lvchange_background_polling(cmd, lv))
+	    !_lvchange_background_polling(cmd, lv, 1))
 		return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, monitor_ARG) &&
-	    !_lvchange_monitoring(cmd, lv))
+	    !_lvchange_monitoring(cmd, lv, 1))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -1584,11 +1594,11 @@ static int _lvchange_monitor_poll_single(struct cmd_context *cmd,
 				         struct processing_handle *handle)
 {
 	if (arg_is_set(cmd, monitor_ARG) &&
-	    !_lvchange_monitoring(cmd, lv))
+	    !_lvchange_monitoring(cmd, lv, 0))
 		return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, poll_ARG) &&
-	    !_lvchange_background_polling(cmd, lv))
+	    !_lvchange_background_polling(cmd, lv, 0))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index b2c739c..24c2253 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -42,7 +42,16 @@ static int _monitor_lvs_in_vg(struct cmd_context *cmd,
 		if (lv_is_pvmove(lv))
 			continue;
 
-		if (!monitor_dev_for_events(cmd, lv, 0, reg)) {
+		if (locking_is_clustered()) {
+			if (lv != lv_lock_holder(lv))
+				continue;
+			if (!lv_refresh(cmd, lv)) {
+				stack;
+				r = 0;
+				continue;
+			}
+		} else if (!monitor_dev_for_events(cmd, lv, 0, reg)) {
+			stack;
 			r = 0;
 			continue;
 		}
@@ -157,8 +166,10 @@ static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg
 
 	if (lvs_in_vg_activated(vg) &&
 	    dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
-		if (!_monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode(), &monitored))
+		if (!_monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode(), &monitored)) {
+			stack;
 			r = 0;
+		}
 		log_print_unless_silent("%d logical volume(s) in volume group "
 					"\"%s\" %smonitored",
 					monitored, vg->name, (dmeventd_monitor_mode()) ? "" : "un");


