From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jun 2009 14:43:59 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090609144359.12241.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-09 14:43:59

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1143&r2=1.1144

--- LVM2/WHATS_NEW	2009/06/06 22:00:20	1.1143
+++ LVM2/WHATS_NEW	2009/06/09 14:43:59	1.1144
@@ -1,5 +1,7 @@
 Version 2.02.48 - 
 ===============================
+  Update vgrename, vgsplit, and vgcreate to use vg_lock_newname.
+  Add vg_lock_newname() library function.
   Round up requested readahead to at least one page and print warning.
   Try to repair vg before actual vgremove when force flag provided.
   Fix possible double release of VG after recovery.


