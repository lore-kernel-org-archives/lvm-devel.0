From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jul 2007 17:51:26 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20070710175126.10593.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-10 17:51:26

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Call dev_iter_destroy() if _process_all_devs() is interrupted by sigint.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.649&r2=1.650
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/WHATS_NEW	2007/07/09 15:40:42	1.649
+++ LVM2/WHATS_NEW	2007/07/10 17:51:26	1.650
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Call dev_iter_destroy() if _process_all_devs() is interrupted by sigint.
   Add vg_mda_count and pv_mda_count columns to reports.
   Fix dumpconfig to use log_print instead of stdout directly.
   Remove unused parameter 'fid' from _add_pv_to_vg.
--- LVM2/tools/toollib.c	2007/06/19 04:36:12	1.101
+++ LVM2/tools/toollib.c	2007/07/10 17:51:26	1.102
@@ -659,7 +659,7 @@
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
-			return ret_max;
+			break;
 	}
 
 	dev_iter_destroy(iter);


