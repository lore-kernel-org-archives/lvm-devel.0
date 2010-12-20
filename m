From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 14:04:44 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20101220140444.22670.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 14:04:43

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Remove dead assignment of segh
	
	Variable 'segh' is never read again after this assignment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.208&r2=1.209

--- LVM2/lib/activate/dev_manager.c	2010/12/08 19:26:36	1.208
+++ LVM2/lib/activate/dev_manager.c	2010/12/20 14:04:43	1.209
@@ -526,7 +526,7 @@
 						 total_numerator, total_denominator);
 	} while (next);
 
-	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
+	if (lv && dm_list_next(&lv->segments, segh)) {
 		log_error("Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;
@@ -620,7 +620,7 @@
 
 	} while (next);
 
-	if ((segh = dm_list_next(&lv->segments, segh))) {
+	if (dm_list_next(&lv->segments, segh)) {
 		log_error("Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;


