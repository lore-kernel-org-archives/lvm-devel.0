From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 4 Feb 2011 20:30:21 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20110204203021.11699.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-02-04 20:30:19

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c activate.h dev_manager.c 
	lib/locking    : locking.c locking.h 
	lib/metadata   : lv_manip.c 
	tools          : vgchange.c 

Log message:
	Allow snapshots in a cluster as long as they are exclusively
	activated.
	
	In order to achieve this, we need to be able to query whether
	the origin is active exclusively (a condition of being able to
	add an exclusive snapshot).
	
	Once we are able to query the exclusive activation of an LV, we
	can safely create/activate the snapshot.
	
	A change to 'hold_lock' was also made so that a request to aquire
	a WRITE lock did not replace an EX lock, which is already a form
	of write lock.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1905&r2=1.1906
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.190&r2=1.191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.212&r2=1.213
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.246&r2=1.247
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/WHATS_NEW	2011/02/04 19:33:53	1.1905
+++ LVM2/WHATS_NEW	2011/02/04 20:30:17	1.1906
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Allow exclusive activation of snapshots in a cluster.
   Add --addnodeonresume, --addnodeoncreate options for dmsetup create.
   Use cluster-wide message to request device name sync.
   Fix operation node stacking for consecutive dm ops.
--- LVM2/daemons/clvmd/lvm-functions.c	2011/02/04 19:21:47	1.110
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/02/04 20:30:17	1.111
@@ -240,9 +240,17 @@
 
 	lvi = lookup_info(resource);
 
-	if (lvi && lvi->lock_mode == mode) {
-		DEBUGLOG("hold_lock, lock mode %d already held\n", mode);
-		return 0;
+	if (lvi) {
+		if (lvi->lock_mode == mode) {
+			DEBUGLOG("hold_lock, lock mode %d already held\n",
+				 mode);
+			return 0;
+		}
+		if ((lvi->lock_mode == LCK_EXCL) && (mode == LCK_WRITE)) {
+			DEBUGLOG("hold_lock, lock already held LCK_EXCL, "
+				 "ignoring LCK_WRITE request");
+			return 0;
+		}
 	}
 
 	/* Only allow explicit conversions */
--- LVM2/lib/activate/activate.c	2011/02/04 19:14:40	1.190
+++ LVM2/lib/activate/activate.c	2011/02/04 20:30:18	1.191
@@ -708,39 +708,108 @@
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
+int lv_is_active_exclusive_remotely(struct logical_volume *lv)
+{
+	int l, e;
+	return _lv_is_active(lv, &l, &e) && !l && e;
 }
 
 #ifdef DMEVENTD
--- LVM2/lib/activate/activate.h	2011/01/10 14:02:31	1.73
+++ LVM2/lib/activate/activate.h	2011/02/04 20:30:18	1.74
@@ -94,6 +94,8 @@
 int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(struct logical_volume *lv);
+int lv_is_active_exclusive_locally(struct logical_volume *lv);
+int lv_is_active_exclusive_remotely(struct logical_volume *lv);
 
 int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 		       const char *layer, const char *target_type);
--- LVM2/lib/activate/dev_manager.c	2011/01/10 14:02:31	1.212
+++ LVM2/lib/activate/dev_manager.c	2011/02/04 20:30:18	1.213
@@ -1390,10 +1390,6 @@
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
--- LVM2/lib/locking/locking.c	2011/02/02 13:34:00	1.91
+++ LVM2/lib/locking/locking.c	2011/02/04 20:30:18	1.92
@@ -545,7 +545,7 @@
 	return (_locking.flags & LCK_CLUSTERED) ? 1 : 0;
 }
 
-int remote_lock_held(const char *vol)
+int remote_lock_held(const char *vol, int *exclusive)
 {
 	int mode = LCK_NULL;
 
@@ -563,5 +563,8 @@
 		return 1;
 	}
 
+	if (exclusive)
+		*exclusive = (mode == LCK_EXCL);
+
 	return mode == LCK_NULL ? 0 : 1;
 }
--- LVM2/lib/locking/locking.h	2011/02/04 19:18:17	1.61
+++ LVM2/lib/locking/locking.h	2011/02/04 20:30:18	1.62
@@ -25,7 +25,7 @@
 int vg_write_lock_held(void);
 int locking_is_clustered(void);
 
-int remote_lock_held(const char *vol);
+int remote_lock_held(const char *vol, int *exclusive);
 
 /*
  * LCK_VG:
--- LVM2/lib/metadata/lv_manip.c	2011/01/28 02:58:01	1.246
+++ LVM2/lib/metadata/lv_manip.c	2011/02/04 20:30:18	1.247
@@ -3164,11 +3164,6 @@
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
@@ -3217,6 +3212,13 @@
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
 
--- LVM2/tools/vgchange.c	2011/01/24 13:38:32	1.118
+++ LVM2/tools/vgchange.c	2011/02/04 20:30:19	1.119
@@ -115,6 +115,16 @@
 		    ((lv->status & PVMOVE) ))
 			continue;
 
+		/*
+		 * If the LV is active exclusive remotely,
+		 * then ignore it here
+		 */
+		if (lv_is_active_exclusive_remotely(lv)) {
+			log_verbose("%s/%s is exclusively active on"
+				    " a remote node", vg->name, lv->name);
+			continue;
+		}
+
 		expected_count++;
 
 		if (activate == CHANGE_AN) {


