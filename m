From: agk@sourceware.org <agk@sourceware.org>
Date: 28 May 2009 01:59:38 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20090528015938.2790.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-28 01:59:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	When creating new LV, double-check that name is not already in use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1131&r2=1.1132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177

--- LVM2/WHATS_NEW	2009/05/28 01:11:29	1.1131
+++ LVM2/WHATS_NEW	2009/05/28 01:59:37	1.1132
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  When creating new LV, double-check that name is not already in use.
   Remove /dev/vgname/lvname symlink automatically if LV is no longer visible.
   Rename internal vorigin LV to match visible LV.
   Suppress 'removed' messages displayed when internal LVs are removed.
--- LVM2/lib/metadata/lv_manip.c	2009/05/28 00:29:15	1.176
+++ LVM2/lib/metadata/lv_manip.c	2009/05/28 01:59:37	1.177
@@ -1844,6 +1844,10 @@
 		log_error("Failed to generate unique name for the new "
 			  "logical volume");
 		return NULL;
+	} else if (find_lv_in_vg(vg, name)) {
+		log_error("Unable to create LV %s in Volume Group %s: "
+			  "name already in use.", name, vg->name);
+		return NULL;
 	}
 
 	log_verbose("Creating logical volume %s", name);


