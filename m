From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Aug 2008 18:41:51 -0000
Subject: LVM2 ./WHATS_NEW lib/uuid/uuid.c lib/uuid/uuid ...
Message-ID: <20080828184151.15620.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-28 18:41:51

Modified files:
	.              : WHATS_NEW 
	lib/uuid       : uuid.c uuid.h 
	tools          : vgconvert.c 

Log message:
	Fix vgconvert logical volume id metadata validation.
	
	If volume group is downconverted to lvm1 format,
	check if lvid has supported format for conversion to lv_num in lvm1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.948&r2=1.949
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2008/08/28 10:40:44	1.948
+++ LVM2/WHATS_NEW	2008/08/28 18:41:50	1.949
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Fix vgconvert logical volume id metadata validation.
   Fix lvmdump metadata gather option (-m) to work correctly.
   Fix allocation bug in text metadata format write error path.
   Fix vgcfgbackup to properly check filename if template is used.
--- LVM2/lib/uuid/uuid.c	2008/08/07 13:59:49	1.25
+++ LVM2/lib/uuid/uuid.c	2008/08/28 18:41:51	1.26
@@ -67,11 +67,29 @@
 		lv_num *= sizeof(_c) - 1;
 		if ((c = strchr(_c, lvid->id[1].uuid[i])))
 			lv_num += (int) (c - _c);
+		if (lv_num < 0)
+			lv_num = 0;
 	}
 
 	return lv_num;
 }
 
+int lvid_in_restricted_range(union lvid *lvid)
+{
+	int i;
+
+	for (i = 0; i < ID_LEN - 3; i++)
+		if (lvid->id[1].uuid[i] != '0')
+			return 0;
+
+	for (i = ID_LEN - 3; i < ID_LEN; i++)
+		if (!isdigit(lvid->id[1].uuid[i]))
+			return 0;
+
+	return 1;
+}
+
+
 int id_create(struct id *id)
 {
 	int randomfile;
--- LVM2/lib/uuid/uuid.h	2007/08/20 20:55:27	1.15
+++ LVM2/lib/uuid/uuid.h	2008/08/28 18:41:51	1.16
@@ -34,6 +34,7 @@
 
 int lvid_from_lvnum(union lvid *lvid, struct id *vgid, uint32_t lv_num);
 int lvnum_from_lvid(union lvid *lvid);
+int lvid_in_restricted_range(union lvid *lvid);
 
 void uuid_from_num(char *uuid, uint32_t num);
 
--- LVM2/tools/vgconvert.c	2008/06/24 20:10:32	1.28
+++ LVM2/tools/vgconvert.c	2008/08/28 18:41:51	1.29
@@ -81,6 +81,17 @@
 		return ECMD_FAILED;
 	}
 
+	/* If converting to restricted lvid, check if lvid is compatible */
+	if (!(vg->fid->fmt->features & FMT_RESTRICTED_LVIDS) &&
+	    cmd->fmt->features & FMT_RESTRICTED_LVIDS)
+		list_iterate_items(lvl, &vg->lvs)
+			if (!lvid_in_restricted_range(&lvl->lv->lvid)) {
+				log_error("Logical volume %s lvid format is"
+					  " incompatible with requested"
+					  " metadata format.", lvl->lv->name);
+				return ECMD_FAILED;
+			}
+
 	/* Attempt to change any LVIDs that are too big */
 	if (cmd->fmt->features & FMT_RESTRICTED_LVIDS) {
 		list_iterate_items(lvl, &vg->lvs) {


