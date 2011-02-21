From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:07:04 -0000
Subject: LVM2/lib cache/lvmcache.c format_text/archive. ...
Message-ID: <20110221120704.25979.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:07:03

Modified files:
	lib/cache      : lvmcache.c 
	lib/format_text: archive.c archiver.c format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Change the code throughout for recent changes in format_instance handling.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.425&r2=1.426

--- LVM2/lib/cache/lvmcache.c	2011/02/18 14:16:11	1.103
+++ LVM2/lib/cache/lvmcache.c	2011/02/21 12:07:03	1.104
@@ -629,6 +629,7 @@
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg;
 	struct format_instance *fid;
+	struct format_instance_ctx fic;
 
 	if (!vgid || !(vginfo = vginfo_from_vgid(vgid)) || !vginfo->vgmetadata)
 		return NULL;
@@ -652,9 +653,10 @@
 	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
-	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
-						      vginfo->vgname,
-						      vgid, NULL)))
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vginfo->vgname;
+	fic.context.vg_ref.vg_id = vgid;
+	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic)))
 		return_NULL;
 
 	/* Build config tree from vgmetadata, if not yet cached */
--- LVM2/lib/format_text/archive.c	2010/12/08 20:50:49	1.40
+++ LVM2/lib/format_text/archive.c	2011/02/21 12:07:03	1.41
@@ -300,16 +300,16 @@
 {
 	struct volume_group *vg = NULL;
 	struct format_instance *tf;
+	struct format_instance_ctx fic;
 	time_t when;
 	char *desc;
-	void *context;
 
 	log_print(" ");
 	log_print("File:\t\t%s", af->path);
 
-	if (!(context = create_text_context(cmd, af->path, NULL)) ||
-	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
-							 NULL, context))) {
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
+	if (!(fic.context.private = create_text_context(cmd, af->path, NULL)) ||
+	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create text instance object.");
 		return;
 	}
--- LVM2/lib/format_text/archiver.c	2011/01/28 10:16:04	1.38
+++ LVM2/lib/format_text/archiver.c	2011/02/21 12:07:03	1.39
@@ -270,13 +270,12 @@
 {
 	struct volume_group *vg = NULL;
 	struct format_instance *tf;
+	struct format_instance_ctx fic;
 	struct metadata_area *mda;
-	void *context;
 
-	if (!(context = create_text_context(cmd, file,
-					    cmd->cmd_line)) ||
-	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
-							 NULL, context))) {
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
+	if (!(fic.context.private = create_text_context(cmd, file, cmd->cmd_line)) ||
+	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create text format object.");
 		return NULL;
 	}
@@ -297,6 +296,8 @@
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 	struct lvmcache_info *info;
+	struct format_instance *fid;
+	struct format_instance_ctx fic;
 
 	/*
 	 * FIXME: Check that the PVs referenced in the backup are
@@ -304,8 +305,10 @@
 	 */
 
 	/* Attempt to write out using currently active format */
-	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg->name,
-						       NULL, NULL))) {
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vg->name;
+	fic.context.vg_ref.vg_id = NULL;
+	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
 		log_error("Failed to allocate format instance");
 		return 0;
 	}
@@ -386,17 +389,17 @@
 {
 	int r = 0;
 	struct format_instance *tf;
+	struct format_instance_ctx fic;
 	struct metadata_area *mda;
-	void *context;
 	struct cmd_context *cmd;
 
 	cmd = vg->cmd;
 
 	log_verbose("Creating volume group backup \"%s\" (seqno %u).", file, vg->seqno);
 
-	if (!(context = create_text_context(cmd, file, desc)) ||
-	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
-							 NULL, context))) {
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
+	if (!(fic.context.private = create_text_context(cmd, file, desc)) ||
+	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, &fic))) {
 		log_error("Couldn't create backup object.");
 		return 0;
 	}
--- LVM2/lib/format_text/format-text.c	2011/02/21 12:05:50	1.156
+++ LVM2/lib/format_text/format-text.c	2011/02/21 12:07:03	1.157
@@ -1056,6 +1056,7 @@
 	DIR *d;
 	struct volume_group *vg;
 	struct format_instance *fid;
+	struct format_instance_ctx fic;
 	char path[PATH_MAX];
 	char *scanned_vgname;
 
@@ -1086,8 +1087,10 @@
 				}
 
 				/* FIXME stat file to see if it's changed */
-				fid = _text_create_text_instance(fmt, NULL, NULL,
-							    NULL);
+				/* FIXME: Check this fid is OK! */
+				fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_PRIVATE_MDAS;
+				fic.context.private = NULL;
+				fid = _text_create_text_instance(fmt, &fic);
 				if ((vg = _vg_read_file_name(fid, scanned_vgname,
 							     path))) {
 					/* FIXME Store creation host in vg */
--- LVM2/lib/metadata/metadata.c	2011/02/21 12:05:50	1.425
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:07:03	1.426
@@ -906,6 +906,7 @@
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 {
 	struct volume_group *vg;
+	struct format_instance_ctx fic;
 	int consistent = 0;
 	struct dm_pool *mem;
 	uint32_t rc;
@@ -979,8 +980,10 @@
 	/* initialize removed_pvs list */
 	dm_list_init(&vg->removed_pvs);
 
-	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
-						       NULL, NULL))) {
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vg_name;
+	fic.context.vg_ref.vg_id = NULL;
+	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
 		log_error("Failed to create format instance");
 		goto bad;
 	}
@@ -2604,6 +2607,7 @@
 					     int warnings,
 					     const char *orphan_vgname)
 {
+	struct format_instance_ctx fic;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 	struct pv_list *pvl;
@@ -2635,9 +2639,10 @@
 	}
 
 	/* create format instance with appropriate metadata area */
-	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
-							  orphan_vgname, NULL,
-							  NULL))) {
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = orphan_vgname;
+	fic.context.vg_ref.vg_id = NULL;
+	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic))) {
 		log_error("Failed to create format instance");
 		goto bad;
 	}
@@ -2742,6 +2747,7 @@
 				     int *consistent, unsigned precommitted)
 {
 	struct format_instance *fid;
+	struct format_instance_ctx fic;
 	const struct format_type *fmt;
 	struct volume_group *vg, *correct_vg = NULL;
 	struct metadata_area *mda;
@@ -2814,7 +2820,10 @@
 		use_precommitted = 0;
 
 	/* create format instance with appropriate metadata area */
-	if (!(fid = fmt->ops->create_instance(fmt, vgname, vgid, NULL))) {
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vgname;
+	fic.context.vg_ref.vg_id = vgid;
+	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
 		log_error("Failed to create format instance");
 		return NULL;
 	}
@@ -2969,7 +2978,10 @@
 			use_precommitted = 0;
 
 		/* create format instance with appropriate metadata area */
-		if (!(fid = fmt->ops->create_instance(fmt, vgname, vgid, NULL))) {
+		fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+		fic.context.vg_ref.vg_name = vgname;
+		fic.context.vg_ref.vg_id = vgid;
+		if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
 			log_error("Failed to create format instance");
 			return NULL;
 		}


