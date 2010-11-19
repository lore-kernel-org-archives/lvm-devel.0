From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Nov 2010 13:17:28 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-report.c
Message-ID: <20101119131728.5314.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-19 13:17:28

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-report.c 

Log message:
	Fix _output_field crash from field_id free with DEBUG_MEM. (Phillip Susi)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.423&r2=1.424
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW_DM	2010/11/09 02:58:06	1.423
+++ LVM2/WHATS_NEW_DM	2010/11/19 13:17:27	1.424
@@ -1,5 +1,6 @@
 Version 1.02.58 - 
 ===================================
+  Fix _output_field crash from field_id free with DEBUG_MEM. (1.02.57)
 
 Version 1.02.57 - 8th November 2010
 ===================================
--- LVM2/libdm/libdm-report.c	2010/11/01 13:50:51	1.39
+++ LVM2/libdm/libdm-report.c	2010/11/19 13:17:27	1.40
@@ -929,7 +929,7 @@
 			return 0;
 		}
 
-		free(field_id);
+		dm_free(field_id);
 
 		if (!dm_pool_grow_object(rh->mem, "=", 1)) {
 			log_error("dm_report: Unable to extend output line");


