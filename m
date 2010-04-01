From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 11:45:39 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100401114539.14971.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 11:45:37

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Improve vg_validate to detect some loops in lists.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.327&r2=1.328

--- LVM2/lib/metadata/metadata.c	2010/04/01 11:43:26	1.327
+++ LVM2/lib/metadata/metadata.c	2010/04/01 11:45:36	1.328
@@ -2253,6 +2253,12 @@
 			}
 		}
 
+		if (!check_lv_segments(lvl->lv, 0)) {
+			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
+				  lvl->lv->name);
+			r = 0;
+		}
+
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);


