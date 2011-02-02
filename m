From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 02 Feb 2011 12:07:46 -0600
Subject: [PATCHv3 2 of 2]LVM: allow exclusive snapshots in cluster
Message-ID: <1296670066.27798.18.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks to those who've given feedback so far.

I've gone with a suggestion to add new functions rather that use enum's
or defines as the return values.

This patch iteration attempts to avoid the extra network operation that
took place for cluster VGs - even when it wasn't needed most times.

I have noticed a couple curious things while testing:

A) the exclusive flag on an LV is lost after the following operations:
	1) lvchange -aey vg/lv
	2) lvcreate -s -n snap vg/lv
	3) lvremove vg/snap
	4) lvcreate -s -n snap vg/lv - fails because lv is !EX
I don't think this is a result of the changes I've made, but an oddity
that has not been discovered yet.

B) 'vgchange -ay' returns success on only one node (as mbroz
highlighted) when there are snapshots in a cluster because only one node
can activate all the LVs.  The other LVs on the remaining nodes still
activate properly.

 brassow


Allow snapshots in a cluster as long as they are exclusively
activated.

In order to achieve this, we need to be able to query whether
the origin is active exclusively (a condition of being able to
add an exclusive snapshot).

Index: LVM2/lib/activate/activate.c
===================================================================
--- LVM2.orig/lib/activate/activate.c
+++ LVM2/lib/activate/activate.c
@@ -696,40 +696,111 @@ int lvs_in_vg_opened(const struct volume
 }
 
 /*
+ * _lv_is_active
+ * @lv:        logical volume being queried
+ * @locally:   set if active locally (when provided)
+ * @exclusive: set if active exclusively (when provided)
+ *
  * Determine whether an LV is active locally or in a cluster.
- * Assumes vg lock held.
- * Returns:
- * 0 - not active locally or on any node in cluster
- * 1 - active either locally or some node in the cluster
+ * In addition to the return code which indicates whether or
+ * not the LV is active somewhere, two other values are set
+ * to yield more information about the status of the activation:
+ *	return	locally	exclusively	status
+ *	======	=======	===========	======
+ *	   0	   0	    0		not active
+ *	   1	   0	    0		active remotely
+ *	   1	   0	    1		exclusive remotely
+ *	   1	   1	    0		active locally and possibly remotely
+ *	   1	   1	    1		exclusive locally (or local && !cluster)
+ * The VG lock must be held to call this function.
+ *
+ * Returns: 0 or 1
  */
-int lv_is_active(struct logical_volume *lv)
+static int _lv_is_active(struct logical_volume *lv,
+			 int *locally, int *exclusive)
 {
-	int ret;
+	int r, l, e; /* remote, local, and exclusive */
+
+	r = l = e = 0;
 
 	if (_lv_active(lv->vg->cmd, lv))
-		return 1;
+		l = 1;
 
-	if (!vg_is_clustered(lv->vg))
-		return 0;
+	if (!vg_is_clustered(lv->vg)) {
+		e = 1;  /* exclusive by definition */
+		goto out;
+	}
+
+	/* Active locally, and the caller doesn't care about exclusive */
+	if (l && !exclusive)
+		goto out;
 
-	if ((ret = remote_lock_held(lv->lvid.s)) >= 0)
-		return ret;
+	if ((r = remote_lock_held(lv->lvid.s, &e)) >= 0)
+		goto out;
 
 	/*
-	 * Old compatibility code if locking doesn't support lock query
-	 * FIXME: check status to not deactivate already activate device
+	 * If lock query is not supported (due to interfacing with old
+	 * code), then we cannot evaluate exclusivity properly.
+	 *
+	 * Old users of this function will never be affected by this,
+	 * since they are only concerned about active vs. not active.
+	 * New users of this function who specifically ask for 'exclusive'
+	 * will be given an error message.
 	 */
+	if (l) {
+		if (exclusive)
+			log_error("Unable to determine exclusivity of %s",
+				  lv->name);
+		goto out;
+	}
+
 	if (activate_lv_excl(lv->vg->cmd, lv)) {
 		if (!deactivate_lv(lv->vg->cmd, lv))
 			stack;
 		return 0;
 	}
 
-	/*
-	 * Exclusive local activation failed so assume it is active elsewhere.
-	 */
-	return 1;
+out:
+	if (locally)
+		*locally = l;
+	if (exclusive)
+		*exclusive = e;
+
+	log_very_verbose("%s/%s is %sactive%s%s",
+			 lv->vg->name, lv->name,
+			 (r || l) ? "" : "not ",
+			 (exclusive && e) ? " exclusive" : "",
+			 e ? (l ? " locally" : " remotely") : "");
+
+	return r || l;
+}
+
+int lv_is_active(struct logical_volume *lv)
+{
+	return _lv_is_active(lv, NULL, NULL);
+}
+
+/*
+int lv_is_active_locally(struct logical_volume *lv)
+{
+	int l;
+	return _lv_is_active(lv, &l, NULL) && l;
+}
+*/
+
+int lv_is_active_exclusive_locally(struct logical_volume *lv)
+{
+	int l, e;
+	return _lv_is_active(lv, &l, &e) && l && e;
+}
+
+/*
+int lv_is_active_exclusive_remotely(struct logical_volume *lv)
+{
+	int l, e;
+	return _lv_is_active(lv, &l, &e) && !l && e;
 }
+*/
 
 #ifdef DMEVENTD
 static struct dm_event_handler *_create_dm_event_handler(struct cmd_context *cmd, const char *dmuuid, const char *dso,
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
@@ -545,7 +545,7 @@ int locking_is_clustered(void)
 	return (_locking.flags & LCK_CLUSTERED) ? 1 : 0;
 }
 
-int remote_lock_held(const char *vol)
+int remote_lock_held(const char *vol, int *exclusive)
 {
 	int mode = LCK_NULL;
 
@@ -563,5 +563,8 @@ int remote_lock_held(const char *vol)
 		return 1;
 	}
 
+	if (exclusive)
+		*exclusive = (mode == LCK_EXCL);
+
 	return mode == LCK_NULL ? 0 : 1;
 }
Index: LVM2/lib/locking/locking.h
===================================================================
--- LVM2.orig/lib/locking/locking.h
+++ LVM2/lib/locking/locking.h
@@ -25,7 +25,7 @@ void reset_locking(void);
 int vg_write_lock_held(void);
 int locking_is_clustered(void);
 
-int remote_lock_held(const char *vol);
+int remote_lock_held(const char *vol, int *exclusive);
 
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
@@ -3217,6 +3212,13 @@ int lv_create_single(struct volume_group
 				return 0;
 			}
 			origin_active = info.exists;
+
+			if (vg_is_clustered(vg) &&
+			    !lv_is_active_exclusive_locally(org)) {
+				log_error("%s must be active exclusively to"
+					  " create snapshot", org->name);
+				return 0;
+			}
 		}
 	}
 
Index: LVM2/lib/activate/activate.h
===================================================================
--- LVM2.orig/lib/activate/activate.h
+++ LVM2/lib/activate/activate.h
@@ -94,6 +94,7 @@ int lvs_in_vg_activated(struct volume_gr
 int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(struct logical_volume *lv);
+int lv_is_active_exclusive_locally(struct logical_volume *lv);
 
 int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 		       const char *layer, const char *target_type);



