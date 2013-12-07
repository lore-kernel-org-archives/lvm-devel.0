From: Raman Shishniou <rommer@activecloud.com>
Date: Sat, 7 Dec 2013 06:08:16 +0300
Subject: [PATCH] Try to convert existing lock on volume reactivation for clustered volume groups.
In-Reply-To: <52A1DFDE.8050706@redhat.com>
References: <52A14E1A.3030509@activecloud.com> <52A18F2B.5070607@redhat.com>
	<52A1DB94.1020001@activecloud.com> <52A1DFDE.8050706@redhat.com>
Message-ID: <52A29120.2000203@activecloud.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvchange/vgchange should set LCK_CONVERT flag in lock_lv_vol() for
activated clustered volumes to try to convert shared lock to exclusive,
and vice versa. It makes possible to create snapshot of opened volume
in case of other cluster nodes deactivate it and drop exclusiveness
after all snapshots are deleted.

Signed-off-by: Raman Shishniou <rommer@activecloud.com>
---
 WHATS_NEW                     |    1 +
 daemons/clvmd/lvm-functions.c |    4 ++--
 lib/locking/cluster_locking.c |    3 +++
 lib/locking/locking.c         |    9 +++++++--
 lib/locking/locking.h         |   10 ++++++----
 lib/metadata/lv.c             |   18 ++++++++++++++----
 6 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 72a61e3..1a53423 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Add support to convert exclusive/shared lock on active clustered volume.
   Return success when inserting dirs and links into device cache.
   Test for remote exclusive activation after activation fails.
   Support lvconvert --merge for thin snapshots.
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index b15732f..451d286 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -137,7 +137,7 @@ static const char *decode_flags(unsigned char flags)
                flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR|" : "",
                flags & LCK_ORIGIN_ONLY_MODE ? "ORIGIN_ONLY|" : "",
                flags & LCK_TEST_MODE ? "TEST|" : "",
-               flags & LCK_CONVERT ? "CONVERT|" : "",
+               flags & LCK_CONVERT_MODE ? "CONVERT|" : "",
                flags & LCK_DMEVENTD_MONITOR_IGNORE ? "DMEVENTD_MONITOR_IGNORE|" : "");
 
        if (len > 1)
@@ -374,7 +374,7 @@ static int do_activate_lv(char *resource, unsigned char command, unsigned char l
         * of exclusive lock to shared one during activation.
         */
        if (command & LCK_CLUSTER_VG) {
-               status = hold_lock(resource, mode, LCKF_NOQUEUE | (lock_flags & LCK_CONVERT ? LCKF_CONVERT:0));
+               status = hold_lock(resource, mode, LCKF_NOQUEUE | (lock_flags & LCK_CONVERT_MODE ? LCKF_CONVERT:0));
                if (status) {
                        /* Return an LVM-sensible error for this.
                         * Forcing EIO makes the upper level return this text
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 7cbb8f1..c94f92b 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -328,6 +328,9 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
        if (flags & LCK_REVERT)
                args[1] |= LCK_REVERT_MODE;
 
+       if (flags & LCK_CONVERT)
+               args[1] |= LCK_CONVERT_MODE;
+
        if (mirror_in_sync())
                args[1] |= LCK_MIRROR_NOSYNC_MODE;
 
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 9433e40..831388e 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -552,8 +552,13 @@ int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv)
        if (lv_is_active_exclusive_locally(lv))
                return 1;
 
-       if (!activate_lv_excl_local(cmd, lv))
-               return_0;
+       if (lv_is_active_locally(lv)) {
+               if (!activate_lv_excl_local_convert(cmd, lv))
+                       return_0;
+       } else {
+               if (!activate_lv_excl_local(cmd, lv))
+                       return_0;
+       }
 
        if (lv_is_active_exclusive(lv))
                return 1;
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index aa42138..cfc7f38 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -103,6 +103,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_CACHE      0x00000100U     /* Operation on cache only using P_ lock */
 #define LCK_ORIGIN_ONLY        0x00000200U     /* Operation should bypass any snapshots */
 #define LCK_REVERT     0x00000400U     /* Revert any incomplete change */
+#define LCK_CONVERT    0x00001000U     /* Try lock conversion */
 
 /*
  * Additional lock bits for cluster communication via args[1]
@@ -110,10 +111,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_PARTIAL_MODE               0x01    /* Partial activation? */
 #define LCK_MIRROR_NOSYNC_MODE         0x02    /* Mirrors don't require sync */
 #define LCK_DMEVENTD_MONITOR_MODE      0x04    /* Register with dmeventd */
-
-/* Not yet used. */
-#define LCK_CONVERT                    0x08    /* Convert existing lock */
-
+#define LCK_CONVERT_MODE               0x08    /* Convert existing lock */
 #define LCK_TEST_MODE                  0x10    /* Test mode: No activation */
 #define LCK_ORIGIN_ONLY_MODE           0x20    /* Same as above */
 #define LCK_DMEVENTD_MONITOR_IGNORE     0x40   /* Whether to ignore dmeventd */
@@ -183,6 +181,8 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define activate_lv(cmd, lv)   lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD)
 #define activate_lv_excl_local(cmd, lv)        \
                                lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_LOCAL)
+#define activate_lv_excl_local_convert(cmd, lv)        \
+                               lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_LOCAL | LCK_CONVERT)
 #define activate_lv_excl_remote(cmd, lv)       \
                                lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_REMOTE)
 
@@ -191,6 +191,8 @@ int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv);
 
 #define activate_lv_local(cmd, lv)     \
        lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL)
+#define activate_lv_local_convert(cmd, lv)     \
+       lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL | LCK_CONVERT)
 #define deactivate_lv_local(cmd, lv)   \
        lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
 #define drop_cached_metadata(vg)       \
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 3e1458c..2cec240 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -773,13 +773,23 @@ deactivate:
                if (_lv_is_exclusive(lv)) {
                        log_verbose("Activating logical volume \"%s\" exclusively locally.",
                                    lv->name);
-                       if (!activate_lv_excl_local(cmd, lv))
-                               return_0;
+                       if (vg_is_clustered(lv->vg) && lv_is_active_locally(lv)) {
+                               if (!activate_lv_excl_local_convert(cmd, lv))
+                                       return_0;
+                       } else {
+                               if (!activate_lv_excl_local(cmd, lv))
+                                       return_0;
+                       }
                } else {
                        log_verbose("Activating logical volume \"%s\" locally.",
                                    lv->name);
-                       if (!activate_lv_local(cmd, lv))
-                               return_0;
+                       if (vg_is_clustered(lv->vg) && lv_is_active_locally(lv)) {
+                               if (!activate_lv_local_convert(cmd, lv))
+                                       return_0;
+                       } else {
+                               if (!activate_lv_local(cmd, lv))
+                                       return_0;
+                       }
                }
                break;
        case CHANGE_AE:
-- 
1.7.1


