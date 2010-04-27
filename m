From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 27 Apr 2010 15:26:59 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20100427152659.26143.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-04-27 15:26:59

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix comment from last commit.  Additionally, there is no need
	to put a comment into the WHATS_NEW file if it is a regression
	that was created and fixed inside the same release window.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1539&r2=1.1540
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW	2010/04/27 14:57:49	1.1539
+++ LVM2/WHATS_NEW	2010/04/27 15:26:58	1.1540
@@ -1,6 +1,5 @@
 Version 2.02.64 -
 =================================
-  Fix regression in down-convert of mirror images with partial PV specification.
   Fix lvconvert error message when existing mirrored LV is not found.
   Disallow the direct removal of a merging snapshot.
   Set appropriate udev flags for reserved LVs.
--- LVM2/lib/metadata/mirror.c	2010/04/27 14:57:49	1.115
+++ LVM2/lib/metadata/mirror.c	2010/04/27 15:26:59	1.116
@@ -811,7 +811,6 @@
 	 * If removable_pvs were specified, then they have been shifted
 	 * to the end to ensure they are removed.  The remaining balance
 	 * of images left to remove will be taken from the unspecified.
-	 * This may not be correct behavior, but it is historical.
 	 */
 	new_area_count = old_area_count - num_removed;
 


