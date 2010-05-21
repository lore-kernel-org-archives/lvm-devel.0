From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:19:23 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20100521121923.4031.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:19:23

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Return ECMD_FAILED for break in process_each_lv() and process_each_segment_in_lv()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1574&r2=1.1575
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.197&r2=1.198

--- LVM2/WHATS_NEW	2010/05/20 23:21:53	1.1574
+++ LVM2/WHATS_NEW	2010/05/21 12:19:22	1.1575
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Return ECMD_FAILED for break in process_each_lv() and process_each_segment_in_lv().
 
 Version 2.02.66 - 20th May 2010
 ===============================
--- LVM2/tools/toollib.c	2010/05/06 11:15:56	1.197
+++ LVM2/tools/toollib.c	2010/05/21 12:19:22	1.198
@@ -329,8 +329,9 @@
 		unlock_and_release_vg(cmd, vg, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
+		/* FIXME: logic for breaking command is not consistent */
 		if (sigint_caught())
-			break;
+			return ECMD_FAILED;
 	}
 
 	return ret_max;
@@ -408,8 +409,9 @@
 		ret = process_single_seg(cmd, seg, handle);
 		if (ret > ret_max)
 			ret_max = ret;
+		/* FIXME: logic for breaking command is not consistent */
 		if (sigint_caught())
-			break;
+			return ECMD_FAILED;
 	}
 
 	return ret_max;


