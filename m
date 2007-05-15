From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 May 2007 13:01:42 -0000
Subject: LVM2 ./WHATS_NEW tools/vgsplit.c
Message-ID: <20070515130142.7227.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-05-15 13:01:41

Modified files:
	.              : WHATS_NEW 
	tools          : vgsplit.c 

Log message:
	Fix and clarify vgsplit error messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.616&r2=1.617
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2007/05/14 11:27:33	1.616
+++ LVM2/WHATS_NEW	2007/05/15 13:01:40	1.617
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Fix and clarify vgsplit error messages.
   Fix a segfault if a device has no target (no table)
   Add some more debuglogs to clvmd startup.
   Misc clvmd cleanups
--- LVM2/tools/vgsplit.c	2007/03/23 12:43:17	1.24
+++ LVM2/tools/vgsplit.c	2007/05/15 13:01:41	1.25
@@ -145,13 +145,16 @@
 		list_iterate_items(seg, &lv->segments) {
 			cow_from = _lv_is_in_vg(vg_from, seg->cow);
 			origin_from = _lv_is_in_vg(vg_from, seg->origin);
+
+			if (cow_from && origin_from)
+				continue;
+			if ((!cow_from && origin_from) ||
+			     (cow_from && !origin_from)) {
+				log_error("Can't split snapshot %s between"
+					  " two Volume Groups", seg->cow->name);
+				return 0;
+			}
 		}
-		if (cow_from && origin_from)
-			continue;
-		if ((!cow_from && origin_from) || (cow_from && !origin_from)) {
-			log_error("Snapshot %s split", seg->cow->name);
-			return 0;
-		}	
 
 		/* Move this snapshot */
 		list_del(lvh);
@@ -190,7 +193,8 @@
 		if ((seg_in && seg_in < seg->area_count) || 
 		    (seg_in && seg->log_lv && !log_in) || 
 		    (!seg_in && seg->log_lv && log_in)) {
-			log_error("Mirror %s split", lv->name);
+			log_error("Can't split mirror %s between "
+				  "two Volume Groups", lv->name);
 			return 0;
 		}
 


