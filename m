From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:55:32 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20100521125532.22463.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:55:25

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h replicator_manip.c 

Log message:
	Replicator: add find_replicator_vgs
	
	Adding find_replicator_vgs() function to find all needed
	VGs for replicator-dev LV.
	
	This function is later called before taking lock_vol().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1583&r2=1.1584
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/replicator_manip.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2010/05/21 12:52:01	1.1583
+++ LVM2/WHATS_NEW	2010/05/21 12:55:25	1.1584
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Add find_replicator_vgs() to discover all needed VGs for replicator-dev LV.
   Add functions for handling cmd_vg structure.
   Extend _lv_each_dependency() with Replicator dependencies.
   Add check_replicator_segment() for catching internal Replicator errors.
--- LVM2/lib/metadata/metadata-exported.h	2010/05/21 12:52:01	1.149
+++ LVM2/lib/metadata/metadata-exported.h	2010/05/21 12:55:25	1.150
@@ -815,6 +815,8 @@
 int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs);
 void cmd_vg_release(struct dm_list *cmd_vgs);
 
+int find_replicator_vgs(struct logical_volume *lv);
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
--- LVM2/lib/metadata/replicator_manip.c	2010/05/21 12:52:01	1.3
+++ LVM2/lib/metadata/replicator_manip.c	2010/05/21 12:55:25	1.4
@@ -602,3 +602,35 @@
 		cvl->vg = NULL;
 	}
 }
+
+/**
+ * Find all needed remote VGs for processing given LV.
+ * Missing VGs are added to VG's cmd_vg list and flag cmd_missing_vgs is set.
+ */
+int find_replicator_vgs(struct logical_volume *lv)
+{
+	struct replicator_site *rsite;
+	int ret = 1;
+
+	if (!lv_is_replicator_dev(lv))
+		return 1;
+
+	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
+		if (!rsite->vg_name || !lv->vg->cmd_vgs ||
+		    cmd_vg_lookup(lv->vg->cmd_vgs, rsite->vg_name, NULL))
+			continue;
+		ret = 0;
+		/* Using cmd memory pool for cmd_vg list allocation */
+		if (!cmd_vg_add(lv->vg->cmd->mem, lv->vg->cmd_vgs,
+				rsite->vg_name, NULL, 0)) {
+			lv->vg->cmd_missing_vgs = 0; /* do not retry */
+			stack;
+			break;
+		}
+
+		log_debug("VG: %s added as missing.", rsite->vg_name);
+		lv->vg->cmd_missing_vgs++;
+	}
+
+	return ret;
+}


