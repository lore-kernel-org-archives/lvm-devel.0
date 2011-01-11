From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Jan 2011 17:21:02 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20110111172102.7625.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-11 17:21:02

Modified files:
	lib/metadata   : mirror.c 

Log message:
	s/log_verbose/log_error/ - Increase log level on error message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/lib/metadata/mirror.c	2011/01/11 17:05:09	1.139
+++ LVM2/lib/metadata/mirror.c	2011/01/11 17:21:01	1.140
@@ -1325,10 +1325,9 @@
 			first_area = m * stripes + (log - 1);
 
 			if (!lv_add_log_segment(ah, first_area, img_lvs[m], 0)) {
-				/* error msg already from lv_add_log_segment */
-				log_verbose("Failed to add mirror image segment"
-					    " to %s. Remove new LV and retry.",
-					    img_lvs[m]->name);
+				log_error("Failed to add mirror image segment"
+					  " to %s. Remove new LV and retry.",
+					  img_lvs[m]->name);
 				return 0;
 			}
 		} else {


