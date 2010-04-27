From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 27 Apr 2010 14:57:52 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20100427145752.22317.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-04-27 14:57:49

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Patch to fix bug 586021 and mantain historical behavior of
	being able to remove more images from a mirror than the
	number of PVs directly specified for removal.
	
	The effort to fix bug 581611 corrected a bug that was unnoticed
	at the time.  The loop in _remove_mirror_images that looks over
	the specified PVs was allowing devices that were previously
	counted and moved to the end of the list to be double-counted.
	This resulted in the number of devices needed for removal always
	being satisfied - even if the user did not specify enough PVs
	for removal to satisfy the request.  When 581611 was fixed, this
	double-counting no longer took place and the result was to remove
	only the minimum of the number of PVs specified or the number
	that was asked to be removed.
	
	By simply always setting 'new_area_count' (as used to be done
	only in the else statement), we return to the previous behavior.
	Indeed, this is exactly what the double-counting was allowing
	to happen before the fix of 581611.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1538&r2=1.1539
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/WHATS_NEW	2010/04/26 18:31:58	1.1538
+++ LVM2/WHATS_NEW	2010/04/27 14:57:49	1.1539
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Fix regression in down-convert of mirror images with partial PV specification.
   Fix lvconvert error message when existing mirrored LV is not found.
   Disallow the direct removal of a merging snapshot.
   Set appropriate udev flags for reserved LVs.
--- LVM2/lib/metadata/mirror.c	2010/04/21 13:55:08	1.114
+++ LVM2/lib/metadata/mirror.c	2010/04/27 14:57:49	1.115
@@ -805,8 +805,15 @@
 		}
 		if (num_removed && old_area_count == new_area_count)
 			return 1;
-	} else
-		new_area_count = old_area_count - num_removed;
+	}
+
+	/*
+	 * If removable_pvs were specified, then they have been shifted
+	 * to the end to ensure they are removed.  The remaining balance
+	 * of images left to remove will be taken from the unspecified.
+	 * This may not be correct behavior, but it is historical.
+	 */
+	new_area_count = old_area_count - num_removed;
 
 	/* Remove mimage LVs from the segment */
 	dm_list_init(&tmp_orphan_lvs);


