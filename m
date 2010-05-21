From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 14:07:24 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20100521140724.17575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 14:07:19

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h replicator_manip.c 

Log message:
	Replicator: add read and release VGs for rsites
	
	Add functions to read and release remote VGs for replicator sites
	in activation context.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1584&r2=1.1585
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/replicator_manip.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2010/05/21 12:55:25	1.1584
+++ LVM2/WHATS_NEW	2010/05/21 14:07:16	1.1585
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Add functions for read and release VGs list.
   Add find_replicator_vgs() to discover all needed VGs for replicator-dev LV.
   Add functions for handling cmd_vg structure.
   Extend _lv_each_dependency() with Replicator dependencies.
--- LVM2/lib/metadata/metadata-exported.h	2010/05/21 12:55:25	1.150
+++ LVM2/lib/metadata/metadata-exported.h	2010/05/21 14:07:17	1.151
@@ -817,6 +817,9 @@
 
 int find_replicator_vgs(struct logical_volume *lv);
 
+int lv_read_replicator_vgs(struct logical_volume *lv);
+void lv_release_replicator_vgs(struct logical_volume *lv);
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
--- LVM2/lib/metadata/replicator_manip.c	2010/05/21 13:34:09	1.5
+++ LVM2/lib/metadata/replicator_manip.c	2010/05/21 14:07:19	1.6
@@ -635,3 +635,59 @@
 
 	return ret;
 }
+
+/**
+ * Read all remote VGs from lv's replicator sites.
+ * Function is used in activation context and needs all VGs already locked.
+ */
+int lv_read_replicator_vgs(struct logical_volume *lv)
+{
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+	struct volume_group *vg;
+
+	if (!lv_is_replicator_dev(lv))
+		return 1;
+
+	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
+		if (!rsite->vg_name)
+			continue;
+		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, 0); // READ_WITHOUT_LOCK
+		if (vg_read_error(vg)) {
+			log_error("Unable to read volume group %s",
+				  rsite->vg_name);
+			goto bad;
+		}
+		rsite->vg = vg;
+		/* FIXME: handling missing LVs needs to be better */
+		dm_list_iterate_items(rdev, &rsite->rdevices)
+			if (!(rdev->lv = find_lv(vg, rdev->name))) {
+				log_error("Unable to find %s in volume group %s",
+					  rdev->name, rsite->vg_name);
+				goto bad;
+			}
+	}
+
+	return 1;
+bad:
+	lv_release_replicator_vgs(lv);
+	return 0;
+}
+
+/**
+ * Release all VG resources taken by lv's replicator sites.
+ * Function is used in activation context and needs all VGs already locked.
+ */
+void lv_release_replicator_vgs(struct logical_volume *lv)
+{
+	struct replicator_site *rsite;
+
+	if (!lv_is_replicator_dev(lv))
+		return;
+
+	dm_list_iterate_back_items(rsite, &first_seg(lv)->replicator->rsites)
+		if (rsite->vg_name && rsite->vg) {
+			vg_release(rsite->vg);
+			rsite->vg = NULL;
+		}
+}


