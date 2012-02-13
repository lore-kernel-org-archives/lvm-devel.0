From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 10:56:32 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20120213105632.8238.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 10:56:31

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 

Log message:
	Clean error paths for format instance
	
	With updated orphan VG code this code needed some updates.
	Add missing log_error for allocation failures.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2282&r2=1.2283
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.190&r2=1.191

--- LVM2/WHATS_NEW	2012/02/13 10:53:31	1.2282
+++ LVM2/WHATS_NEW	2012/02/13 10:56:31	1.2283
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Clean error paths for format instance creation (2.02.91).
   Release vg in error path of _format1_vg_read() instead of just free().
   Report allocation failure for allocation of PV structure.
   Add clvmd init dependency on dlm service when running with new corosync.
--- LVM2/lib/format1/format1.c	2012/02/13 10:53:32	1.144
+++ LVM2/lib/format1/format1.c	2012/02/13 10:56:31	1.145
@@ -580,8 +580,10 @@
 	struct format_instance_ctx fic;
 	struct format_instance *fid;
 
-	if (!fmt)
-		return_NULL;
+	if (!fmt) {
+		log_error("Failed to allocate format1 format type structure.");
+		return NULL;
+	}
 
 	fmt->cmd = cmd;
 	fmt->ops = &_format1_ops;
@@ -607,15 +609,19 @@
 
 	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name))) {
 		log_error("Couldn't create lvm1 orphan VG.");
+		dm_free(fmt);
 		return NULL;
 	}
+
 	fic.type = FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
 	fic.context.vg_ref.vg_id = NULL;
+
 	if (!(fid = _format1_create_instance(fmt, &fic))) {
-		log_error("Couldn't create lvm1 orphan VG format instance.");
-		return NULL;
+		_format1_destroy(fmt);
+		return_NULL;
 	}
+
 	vg_set_fid(fmt->orphan_vg, fid);
 
 	log_very_verbose("Initialised format: %s", fmt->name);
--- LVM2/lib/format_pool/format_pool.c	2012/02/12 23:01:19	1.48
+++ LVM2/lib/format_pool/format_pool.c	2012/02/13 10:56:31	1.49
@@ -320,15 +320,19 @@
 
 	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name))) {
 		log_error("Couldn't create lvm1 orphan VG.");
+		dm_free(fmt);
 		return NULL;
 	}
+
 	fic.type = FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
 	fic.context.vg_ref.vg_id = NULL;
+
 	if (!(fid = _pool_create_instance(fmt, &fic))) {
-		log_error("Couldn't create lvm1 orphan VG format instance.");
+		_pool_destroy(fmt);
 		return NULL;
 	}
+
 	vg_set_fid(fmt->orphan_vg, fid);
 
 	log_very_verbose("Initialised format: %s", fmt->name);
--- LVM2/lib/format_text/format-text.c	2012/02/12 23:01:19	1.190
+++ LVM2/lib/format_text/format-text.c	2012/02/13 10:56:31	1.191
@@ -2270,8 +2270,10 @@
 	const struct dm_config_value *cv;
 	struct mda_lists *mda_lists;
 
-	if (!(fmt = dm_malloc(sizeof(*fmt))))
-		return_NULL;
+	if (!(fmt = dm_malloc(sizeof(*fmt)))) {
+		log_error("Failed to allocate text format type structure.");
+		return NULL;
+	}
 
 	fmt->cmd = cmd;
 	fmt->ops = &_text_handler;
@@ -2296,13 +2298,13 @@
 
 	if (!(fmt->labeller = text_labeller_create(fmt))) {
 		log_error("Couldn't create text label handler.");
-		goto err;
+		goto bad;
 	}
 
 	if (!(label_register_handler(FMT_TEXT_NAME, fmt->labeller))) {
 		log_error("Couldn't register text label handler.");
 		fmt->labeller->ops->destroy(fmt->labeller);
-		goto err;
+		goto bad;
 	}
 
 	if ((cn = find_config_tree_node(cmd, "metadata/dirs"))) {
@@ -2310,13 +2312,13 @@
 			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
 					  "metadata/dirs");
-				goto err;
+				goto bad;
 			}
 
 			if (!_add_dir(cv->v.str, &mda_lists->dirs)) {
 				log_error("Failed to add %s to text format "
 					  "metadata directory list ", cv->v.str);
-				goto err;
+				goto bad;
 			}
 			cmd->independent_metadata_areas = 1;
 		}
@@ -2325,31 +2327,26 @@
 	if ((cn = find_config_tree_node(cmd, "metadata/disk_areas"))) {
 		for (cn = cn->child; cn; cn = cn->sib) {
 			if (!_get_config_disk_area(cmd, cn, &mda_lists->raws))
-				goto err;
+				goto_bad;
 			cmd->independent_metadata_areas = 1;
 		}
 	}
 
-	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name))) {
-		dm_free(fmt);
-		return NULL;
-	}
+	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name)))
+		goto_bad;
 
 	fic.type = FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
 	fic.context.vg_ref.vg_id = NULL;
-	if (!(fid = _text_create_text_instance(fmt, &fic))) {
-		log_error("Failed to create format instance");
-		release_vg(fmt->orphan_vg);
-		goto err;
-	}
+	if (!(fid = _text_create_text_instance(fmt, &fic)))
+		goto_bad;
+
 	vg_set_fid(fmt->orphan_vg, fid);
 
 	log_very_verbose("Initialised format: %s", fmt->name);
 
 	return fmt;
-
-      err:
+bad:
 	_text_destroy(fmt);
 
 	return NULL;


