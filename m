From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 13:04:44 -0000
Subject: LVM2 tools/vgrename.c ./WHATS_NEW
Message-ID: <20080606130444.24050.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 13:04:44

Modified files:
	tools          : vgrename.c 
	.              : WHATS_NEW 

Log message:
	Drop cached metadata when renaming a VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.885&r2=1.886

--- LVM2/tools/vgrename.c	2008/04/30 14:34:02	1.52
+++ LVM2/tools/vgrename.c	2008/06/06 13:04:43	1.53
@@ -133,6 +133,8 @@
 		}
 	}
 
+	drop_cached_metadata(vg_old);
+
 	/* store it on disks */
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg_old) || !vg_commit(vg_old)) {
--- LVM2/WHATS_NEW	2008/06/06 09:48:04	1.885
+++ LVM2/WHATS_NEW	2008/06/06 13:04:44	1.886
@@ -9,6 +9,7 @@
 
 Version 2.02.37 - 
 =================================
+  Drop cached metadata when renaming a VG.
   Allow for vginfo changing during _vg_read.
   Decode numbers in clvmd debugging output.
   Add missing deactivation after activation failure in lvcreate -Zy.


