From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:11:03 -0000
Subject: LVM2/lib format_text/archiver.c metadata/metad ...
Message-ID: <20110221121103.28716.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:10:59

Modified files:
	lib/format_text: archiver.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add vg_set_fid function to change VG format instance.
	
	This function also sets a reference to a new VG format instance for all PVs
	that are part of the VG so the PV-VG interconnection is consistent after the
	change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.426&r2=1.427
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.231&r2=1.232

--- LVM2/lib/format_text/archiver.c	2011/02/21 12:07:03	1.39
+++ LVM2/lib/format_text/archiver.c	2011/02/21 12:10:58	1.40
@@ -308,10 +308,11 @@
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vg->name;
 	fic.context.vg_ref.vg_id = NULL;
-	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
+	if (!(fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
 		log_error("Failed to allocate format instance");
 		return 0;
 	}
+	vg_set_fid(vg, fid);
 
 	/*
 	 * Setting vg->old_name to a blank value will explicitly
--- LVM2/lib/metadata/metadata.c	2011/02/21 12:07:03	1.426
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:10:58	1.427
@@ -3931,6 +3931,16 @@
 	return FAILED_EXIST;
 }
 
+void vg_set_fid(struct volume_group *vg,
+		 struct format_instance *fid)
+{
+	struct pv_list *pvl;
+
+	vg->fid = fid;
+	dm_list_iterate_items(pvl, &vg->pvs)
+		pvl->pv->fid = fid;
+}
+
 static int _convert_key_to_string(const char *key, size_t key_len,
 				  unsigned sub_key, char *buf, size_t buf_len)
 {
--- LVM2/lib/metadata/metadata.h	2011/02/21 12:05:50	1.231
+++ LVM2/lib/metadata/metadata.h	2011/02/21 12:10:59	1.232
@@ -190,6 +190,7 @@
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
+void vg_set_fid(struct volume_group *vg, struct format_instance *fid);
 int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
 		const char *key, size_t key_len, const unsigned sub_key);
 int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas,


