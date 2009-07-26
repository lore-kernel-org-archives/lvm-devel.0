From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 12:41:36 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090726124136.15112.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 12:41:36

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Use vg_size in vg_set_extent_size.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.268&r2=1.269

--- LVM2/lib/metadata/metadata.c	2009/07/26 12:41:09	1.268
+++ LVM2/lib/metadata/metadata.c	2009/07/26 12:41:36	1.269
@@ -758,7 +758,7 @@
 	}
 
 	if (new_size > vg->extent_size) {
-		if ((uint64_t) vg->extent_size * vg->extent_count % new_size) {
+		if ((uint64_t) vg_size(vg) % new_size) {
 			/* FIXME Adjust used PV sizes instead */
 			log_error("New extent size is not a perfect fit");
 			return 0;


