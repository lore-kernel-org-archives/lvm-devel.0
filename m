From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Jun 2010 13:57:29 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20100623135729.10042.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-06-23 13:57:26

Modified files:
	lib/metadata   : mirror.c 

Log message:
	The function that runs to compress a stacked mirror after
	converting from 2-way to 3-way mirror (collapse_mirrored_lv)
	was calling '_remove_mirror_images' with the 'remove_log'
	parameter set.  When the code was put in to fix 599898 to
	honor log parameters during conversion, this argument was
	suddenly being honored.  Thus, when someone would convert from
	a 2-way to 3-way mirror, the log would get removed.
	
	'collapse_mirrored_lv' should not be calling '_remove_mirror_images'
	with 'remove_log' set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/lib/metadata/mirror.c	2010/06/21 16:12:34	1.119
+++ LVM2/lib/metadata/mirror.c	2010/06/23 13:57:26	1.120
@@ -1038,7 +1038,7 @@
 
 		if (!_remove_mirror_images(mirror_seg->lv,
 					   mirror_seg->area_count - 1,
-					   _no_removable_images, NULL, 1, 1, NULL)) {
+					   _no_removable_images, NULL, 0, 1, NULL)) {
 			log_error("Failed to release mirror images");
 			return 0;
 		}


