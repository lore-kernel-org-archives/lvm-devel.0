From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 9 Feb 2012 15:13:43 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120209151343.4767.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-09 15:13:43

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Stop processing lvextend if trying to extend a mirror that is being recovered.
	
	Missing correct return value in lv_extend fn.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2273&r2=1.2274
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.358&r2=1.359

--- LVM2/WHATS_NEW	2012/02/08 13:05:38	1.2273
+++ LVM2/WHATS_NEW	2012/02/09 15:13:42	1.2274
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Stop processing lvextend if trying to extend a mirror that is being recovered.
   Add pool_below_threshold() function to check thin pool percent status.
   Fix test for snap percent for failing merge when removing LV.
   Switch int to void return for str_list_del().
--- LVM2/lib/metadata/lv_manip.c	2012/02/08 13:05:39	1.358
+++ LVM2/lib/metadata/lv_manip.c	2012/02/09 15:13:42	1.359
@@ -2674,6 +2674,7 @@
 				log_error("%s/%s cannot be extended while"
 					  " it is recovering.",
 					  lv->vg->name, lv->name);
+				r = 0;
 				goto out;
 			}
 		}


