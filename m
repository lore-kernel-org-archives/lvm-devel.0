From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 16 Sep 2011 16:41:38 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20110916164138.17664.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-16 16:41:37

Modified files:
	lib/metadata   : mirror.c 

Log message:
	After suspend/resume following a splitmirror op, call sync_local_dev_names
	to settle udev before calling deactivate_lv.
	
	This is an intra-release regression (no WHATS_NEW entry required).  It is
	part of the fix for the current WHATS_NEW entry:
	Work around resume_lv causing error LV scanning during splitmirror operation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170

--- LVM2/lib/metadata/mirror.c	2011/09/14 09:54:21	1.169
+++ LVM2/lib/metadata/mirror.c	2011/09/16 16:41:37	1.170
@@ -747,6 +747,7 @@
 	 *   - commit VG changes
 	 *   - activate the new LV
 	 */
+	sync_local_dev_names(lv->vg->cmd);
 	new_lv = NULL;
 	dm_list_iterate_items(lvl, &split_images) {
 		if (!new_lv) {


