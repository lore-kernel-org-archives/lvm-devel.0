From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Apr 2008 21:34:19 -0000
Subject: LVM2/lib/activate activate.c activate.h
Message-ID: <20080410213419.14041.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-10 21:34:18

Modified files:
	lib/activate   : activate.c activate.h 

Log message:
	Add lv_is_active() to determine whether an lv is active.
	
	Handles non-clustered as well as clustered.  For clustered,
	the best we can do is try exclusive local activation.  If this
	succeeds, we know it is not active elsewhere in the cluster.
	Otherwise, we assume it is active elsewhere.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/lib/activate/activate.c	2008/04/07 10:23:46	1.134
+++ LVM2/lib/activate/activate.c	2008/04/10 21:34:18	1.135
@@ -674,6 +674,38 @@
 }
 
 /*
+ * Determine whether an LV is active locally or in a cluster.
+ * Assumes vg lock held.
+ * Returns:
+ * 0 - not active locally or on any node in cluster
+ * 1 - active either locally or some node in the cluster
+ */
+int lv_is_active(struct logical_volume *lv)
+{
+	if (_lv_active(lv->vg->cmd, lv, 0))
+		return 1;
+
+	if (!vg_is_clustered(lv->vg))
+		return 0;
+
+	/*
+	 * FIXME: Cluster does not report per-node LV activation status.
+	 * Currently the best we can do is try exclusive local activation.
+	 * If that succeeds, we know the LV is not active elsewhere in the
+	 * cluster.
+	 */
+	if (activate_lv_excl(lv->vg->cmd, lv)) {
+		deactivate_lv(lv->vg->cmd, lv);
+		return 0;
+	}
+
+	/*
+	 * Exclusive local activation failed so assume it is active elsewhere.
+	 */
+	return 1;
+}
+
+/*
  * Returns 0 if an attempt to (un)monitor the device failed.
  * Returns 1 otherwise.
  */
--- LVM2/lib/activate/activate.h	2008/04/07 10:23:46	1.60
+++ LVM2/lib/activate/activate.h	2008/04/10 21:34:18	1.61
@@ -91,6 +91,7 @@
 int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg);
 int lvs_in_vg_opened(const struct volume_group *vg);
 
+int lv_is_active(struct logical_volume *lv);
 
 int monitor_dev_for_events(struct cmd_context *cmd,
 			    struct logical_volume *lv, int do_reg);


