From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 11 Oct 2017 08:29:47 -0400
Subject: master - activation: fix activation lock
Message-ID: <201710111229.v9BCTl6E018922@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e02e5b0c5bb3b61a21f4fe2be7f35d2f30054a10
Commit:        e02e5b0c5bb3b61a21f4fe2be7f35d2f30054a10
Parent:        9bd7615fef1e4526bcc2c9fea67d2d038db6d917
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 11 12:41:28 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 11 14:24:28 2017 +0200

activation: fix activation lock

Activation lock has a primary purpose to serialize locking of individual
LV in case there is no other protecting mechanism for parallel
execution.

However in the case an activated LV is composed from several other LVs,
noone should be able to manipulate with those LVs as well.

This patch add a very 'naive' global VG activation locking in this case.
In the future we may introduce smarter function detecting minimal closed
graph components if this will appear as bottleneck

Patch checks if the  VG Write lock is held - in this case we do not
need any more locking - command has exclusive access to VG.

In case we have clustered VG and we are activating an LV which does not
need other LVs - we also do not need any more locks.

In all other cases take respective lock - for single LV - use lvid,
for complex LVs  use vgname.
---
 WHATS_NEW             |    1 +
 lib/locking/locking.h |   18 ++++++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5345f7c..e392722 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Improve selection of resource name for activation lock.
   Avoid cutting 1st. character of resource name for activation lock.
   Support for encrypted devices in fsadm.
   Improve thin pool overprovisioning and repair warning messages.
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 18bce2d..10c26b2 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -174,14 +174,20 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 /*
  * Activation locks are wrapped around activation commands that have to
  * be processed atomically one-at-a-time.
- * If a VG WRITE lock is held, an activation lock is redundant.
+ * If a VG WRITE lock is held or clustered activation activates simple LV
+ * an activation lock is redundant.
  *
- * FIXME Test and support this for thin and cache types.
- * FIXME Add cluster support.
+ * Some LV types do require taking a lock common for whole group of LVs.
+ * TODO: For simplicity reasons ATM take a VG activation global lock and
+ *       later more fine-grained component detection algorithm can be added
  */
-#define lv_supports_activation_locking(lv) (!vg_is_clustered((lv)->vg) && !lv_is_thin_type(lv) && !lv_is_cache_type(lv))
-#define lock_activation(cmd, lv)	(vg_write_lock_held() && lv_supports_activation_locking(lv) ? 1 : lock_vol(cmd, (lv)->lvid.s, LCK_ACTIVATE_LOCK, lv))
-#define unlock_activation(cmd, lv)	(vg_write_lock_held() && lv_supports_activation_locking(lv) ? 1 : lock_vol(cmd, (lv)->lvid.s, LCK_ACTIVATE_UNLOCK, lv))
+
+#define lv_type_requires_activation_lock(lv) ((lv_is_thin_type(lv) || lv_is_cache_type(lv) || lv_is_mirror_type(lv) || lv_is_raid_type(lv) || lv_is_origin(lv) || lv_is_snapshot(lv)) ? 1 : 0)
+#define lv_activation_lock_name(lv) (lv_type_requires_activation_lock(lv) ? (lv)->vg->name : (lv)->lvid.s)
+#define lv_requires_activation_lock_now(lv) ((!vg_write_lock_held() && (!vg_is_clustered((lv)->vg) || !lv_type_requires_activation_lock(lv))) ? 1 : 0)
+
+#define lock_activation(cmd, lv)	(lv_requires_activation_lock_now(lv) ? lock_vol(cmd, lv_activation_lock_name(lv), LCK_ACTIVATE_LOCK, lv) : 1)
+#define unlock_activation(cmd, lv)	(lv_requires_activation_lock_now(lv) ? lock_vol(cmd, lv_activation_lock_name(lv), LCK_ACTIVATE_UNLOCK, lv) : 1)
 
 /*
  * Place temporary exclusive 'activation' lock around an LV locking operation


