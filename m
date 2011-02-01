From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 1 Feb 2011 10:00:20 -0600
Subject: [PATCH 2 of 2] LVM: allow exclusive snapshots in cluster
Message-ID: <201102011600.p11G0KIF019338@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-allow-exclusive-snapshots-in-cluster.patch

Allow snapshots in a cluster as long as they are exclusively
activated.

In order to achieve this, we need to be able to query whether
the origin is active exclusively (a condition of being able to
add an exclusive snapshot).  'lv_is_active' currently only
returns 0 or 1.  This patch will cause 'lv_is_active' to return
'2' if the LV is active exclusively on the calling node.  None
of the callers of 'lv_is_active' are affected by this change.

Once we are able to query the exclusive activation of an LV, we
can safely create/activate the snapshot.

Index: LVM2/lib/activate/activate.c
===================================================================
--- LVM2.orig/lib/activate/activate.c
+++ LVM2/lib/activate/activate.c
@@ -701,20 +701,22 @@ int lvs_in_vg_opened(const struct volume
  * Returns:
  * 0 - not active locally or on any node in cluster
  * 1 - active either locally or some node in the cluster
+ * 2 - active exclusively on this node
  */
 int lv_is_active(struct logical_volume *lv)
 {
-	int ret;
+	int r;
+	int ret = 0;
 
 	if (_lv_active(lv->vg->cmd, lv))
-		return 1;
+		ret++;
 
 	if (!vg_is_clustered(lv->vg))
-		return 0;
-
-	if ((ret = remote_lock_held(lv->lvid.s)) >= 0)
 		return ret;
 
+	if ((r = remote_lock_held(lv->lvid.s, ret)) >= 0)
+		return ret + r;
+
 	/*
 	 * Old compatibility code if locking doesn't support lock query
 	 * FIXME: check status to not deactivate already activate device
Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c
+++ LVM2/lib/activate/dev_manager.c
@@ -1390,10 +1390,6 @@ static int _add_segment_to_dtree(struct 
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
 	} else if (lv_is_origin(seg->lv) && !layer) {
-		if (vg_is_clustered(seg->lv->vg)) {
-			log_error("Clustered snapshots are not yet supported");
-			return 0;
-		}
 		if (lv_is_merging_origin(seg->lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
 			     find_merging_cow(seg->lv)->cow, "cow"))
Index: LVM2/lib/locking/locking.c
===================================================================
--- LVM2.orig/lib/locking/locking.c
+++ LVM2/lib/locking/locking.c
@@ -545,9 +545,9 @@ int locking_is_clustered(void)
 	return (_locking.flags & LCK_CLUSTERED) ? 1 : 0;
 }
 
-int remote_lock_held(const char *vol)
+int remote_lock_held(const char *vol, int exclusive)
 {
-	int mode = LCK_NULL;
+	int m;
 
 	if (!locking_is_clustered())
 		return 0;
@@ -558,10 +558,13 @@ int remote_lock_held(const char *vol)
 	/*
 	 * If an error occured, expect that volume is active
 	 */
-	if (!_locking.query_resource(vol, &mode)) {
+	if (!_locking.query_resource(vol, &m)) {
 		stack;
 		return 1;
 	}
 
-	return mode == LCK_NULL ? 0 : 1;
+	if (exclusive)
+		return m == LCK_EXCL;
+
+	return m == LCK_NULL ? 0 : 1;
 }
Index: LVM2/lib/locking/locking.h
===================================================================
--- LVM2.orig/lib/locking/locking.h
+++ LVM2/lib/locking/locking.h
@@ -25,7 +25,7 @@ void reset_locking(void);
 int vg_write_lock_held(void);
 int locking_is_clustered(void);
 
-int remote_lock_held(const char *vol);
+int remote_lock_held(const char *vol, int exclusive);
 
 /*
  * LCK_VG:
Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -3164,11 +3164,6 @@ int lv_create_single(struct volume_group
 				  "device-mapper kernel driver");
 			return 0;
 		}
-		/* FIXME Allow exclusive activation. */
-		if (vg_is_clustered(vg)) {
-			log_error("Clustered snapshots are not yet supported.");
-			return 0;
-		}
 
 		/* Must zero cow */
 		status |= LVM_WRITE;
@@ -3217,6 +3212,12 @@ int lv_create_single(struct volume_group
 				return 0;
 			}
 			origin_active = info.exists;
+
+			if (vg_is_clustered(vg) && (lv_is_active(org) != 2)) {
+				log_error("%s must be active exclusively to"
+					  " create snapshot", org->name);
+				return 0;
+			}
 		}
 	}
 


