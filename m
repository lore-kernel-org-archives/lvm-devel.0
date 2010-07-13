From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Jul 2010 22:24:40 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20100713222440.15949.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-07-13 22:24:40

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix for bug 614164: No check for existing name when splitting mirror
	
	The user could use the same name as an existing LV when specifying a
	name for an LV split off from a mirror.  This causes all sorts of
	issues.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1667&r2=1.1668
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/WHATS_NEW	2010/07/13 21:48:16	1.1667
+++ LVM2/WHATS_NEW	2010/07/13 22:24:39	1.1668
@@ -1,5 +1,6 @@
 Version 2.02.71 -
 ===============================
+  Check if LV with specified name already exists when splitting a mirror.
   Fix suspend/resume logic for LVs resulting from splitting a mirror.
   Switch cmirrord and clvmd to use dm_create_lockfile.
   Allow clvmd pidfile to be configurable.
--- LVM2/lib/metadata/mirror.c	2010/07/13 21:48:17	1.126
+++ LVM2/lib/metadata/mirror.c	2010/07/13 22:24:39	1.127
@@ -1982,6 +1982,12 @@
 {
 	int r;
 
+	if (find_lv_in_vg(lv->vg, split_name)) {
+		log_error("Logical Volume \"%s\" already exists in "
+			  "volume group \"%s\"", split_name, lv->vg->name);
+		return 0;
+	}
+
 	/* Can't split a mirror that is not in-sync... unless force? */
 	if (!_mirrored_lv_in_sync(lv)) {
 		log_error("Unable to split mirror that is not in-sync.");


