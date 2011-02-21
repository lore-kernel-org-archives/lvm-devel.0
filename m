From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:31:29 -0000
Subject: LVM2 lib/format_text/format-text.c lib/metadat ...
Message-ID: <20110221123129.6196.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:31:28

Modified files:
	lib/format_text: format-text.c 
	lib/metadata   : pv.h 
	tools          : pvchange.c 

Log message:
	Add old_uuid field to struct physical_volume so we can still reference a PV
	with its old UUID when we're changig it (the cache as well as metadata area
	index has the old uuid that we need to use to access the information!)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/lib/format_text/format-text.c	2011/02/21 12:27:26	1.165
+++ LVM2/lib/format_text/format-text.c	2011/02/21 12:31:28	1.166
@@ -1260,6 +1260,7 @@
 {
 	struct text_fid_pv_context *fid_pv_tc;
 	struct format_instance *fid = pv->fid;
+	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct label *label;
 	int64_t label_sector;
 	struct lvmcache_info *info;
@@ -1303,8 +1304,7 @@
 	 * just pass the right format_instance in.
 	 */
 	for (mda_index = 0; mda_index < FMT_TEXT_MAX_MDAS_PER_PV; mda_index++) {
-		if (!(mda = fid_get_mda_indexed(fid, (const char *) &pv->id,
-							ID_LEN, mda_index)))
+		if (!(mda = fid_get_mda_indexed(fid, pvid, ID_LEN, mda_index)))
 			continue;
 
 		mdac = (struct mda_context *) mda->metadata_locn;
@@ -1644,7 +1644,7 @@
 			  struct volume_group *vg)
 {
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (const char *) &pv->id;
+	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	unsigned mda_index;
 	struct metadata_area *pv_mda;
 	struct mda_context *pv_mdac;
@@ -1879,7 +1879,7 @@
 				      unsigned mda_ignored)
 {
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (char *) &pv->id;
+	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	uint64_t pe_start, pe_end;
 	uint64_t alignment, alignment_offset;
 	uint64_t disk_size;
@@ -2099,7 +2099,7 @@
 			   uint64_t size)
 {
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (const char *) &pv->id;
+	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct metadata_area *mda;
 	struct mda_context *mdac;
 	uint64_t size_reduction;
--- LVM2/lib/metadata/pv.h	2011/02/21 12:12:32	1.9
+++ LVM2/lib/metadata/pv.h	2011/02/21 12:31:28	1.10
@@ -22,6 +22,7 @@
 
 struct physical_volume {
 	struct id id;
+	struct id old_id;		/* Set during pvchange -u. */
 	struct device *dev;
 	const struct format_type *fmt;
 	struct format_instance *fid;
--- LVM2/tools/pvchange.c	2011/02/21 12:26:28	1.89
+++ LVM2/tools/pvchange.c	2011/02/21 12:31:28	1.90
@@ -120,6 +120,7 @@
 
 	if (arg_count(cmd, uuid_ARG)) {
 		/* --uuid: Change PV ID randomly */
+		memcpy(&pv->old_id, &pv->id, sizeof(pv->id));
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
 				  pv_name);


