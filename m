From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Aug 2011 21:32:19 -0000
Subject: LVM2/lib metadata/raid_manip.c raid/raid.c
Message-ID: <20110811213219.22981.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-11 21:32:19

Modified files:
	lib/metadata   : raid_manip.c 
	lib/raid       : raid.c 

Log message:
	Various code clean-ups (s/malloc/zalloc/, new msgs, etc)
	
	Fix a couple more issues that kabi found.
	- Add some error messages in failure cases
	- s/malloc/zalloc/
	- use vg->vgmem for lv names instead of vg->cmd->mem

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/lib/metadata/raid_manip.c	2011/08/11 19:17:10	1.2
+++ LVM2/lib/metadata/raid_manip.c	2011/08/11 21:32:18	1.3
@@ -242,7 +242,7 @@
 {
 	int len;
 	char *tmp_name;
-	struct cmd_context *cmd = seg->lv->vg->cmd;
+	struct volume_group *vg = seg->lv->vg;
 	struct logical_volume *data_lv = seg_lv(seg, idx);
 	struct logical_volume *meta_lv = seg_metalv(seg, idx);
 
@@ -262,14 +262,14 @@
 	seg_metatype(seg, idx) = AREA_UNASSIGNED;
 
 	len = strlen(meta_lv->name) + strlen("_extracted") + 1;
-	tmp_name = dm_pool_alloc(cmd->mem, len);
+	tmp_name = dm_pool_alloc(vg->vgmem, len);
 	if (!tmp_name)
 		return_0;
 	sprintf(tmp_name, "%s_extracted", meta_lv->name);
 	meta_lv->name = tmp_name;
 
 	len = strlen(data_lv->name) + strlen("_extracted") + 1;
-	tmp_name = dm_pool_alloc(cmd->mem, len);
+	tmp_name = dm_pool_alloc(vg->vgmem, len);
 	if (!tmp_name)
 		return_0;
 	sprintf(tmp_name, "%s_extracted", data_lv->name);
--- LVM2/lib/raid/raid.c	2011/08/11 14:00:58	1.4
+++ LVM2/lib/raid/raid.c	2011/08/11 21:32:19	1.5
@@ -321,11 +321,13 @@
 static struct segment_type *init_raid_segtype(struct cmd_context *cmd,
 					      const char *raid_type)
 {
-	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
-	if (!segtype)
+	if (!segtype) {
+		log_error("Failed to allocate memory for %s segtype",
+			  raid_type);
 		return_NULL;
-
+	}
 	segtype->cmd = cmd;
 
 	segtype->flags = SEG_RAID;


