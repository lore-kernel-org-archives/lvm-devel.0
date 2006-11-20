From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Nov 2006 16:45:46 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20061120164546.8875.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-20 16:45:45

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Fix check for snapshot module when activating snapshot.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.500&r2=1.501
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW	2006/11/17 02:45:51	1.500
+++ LVM2/WHATS_NEW	2006/11/20 16:45:45	1.501
@@ -1,5 +1,6 @@
 Version 2.02.15 -
 ====================================
+  Fix check for snapshot module when activating snapshot.
   Fix pvremove error path for case when PV is in use.
   Warn if certain duplicate config file entries are seen.
   Enhance lvm_dump.sh for sysreport integration and add man page.
--- LVM2/lib/activate/dev_manager.c	2006/10/18 18:01:51	1.115
+++ LVM2/lib/activate/dev_manager.c	2006/11/20 16:45:45	1.116
@@ -782,12 +782,19 @@
 {
 	uint32_t s;
 	struct list *snh;
+	struct lv_segment *seg_present;
 
 	/* Ensure required device-mapper targets are loaded */
-	if (seg->segtype->ops->target_present &&
-	    !seg->segtype->ops->target_present(seg)) {
+	seg_present = find_cow(seg->lv) ? : seg;
+
+	log_debug("Checking kernel supports %s segment type for %s%s%s",
+		  seg_present->segtype->name, seg->lv->name,
+		  layer ? "-" : "", layer ? : "");
+
+	if (seg_present->segtype->ops->target_present &&
+	    !seg_present->segtype->ops->target_present(seg_present)) {
 		log_error("Can't expand LV %s: %s target support missing "
-			  "from kernel?", seg->lv->name, seg->segtype->name);
+			  "from kernel?", seg->lv->name, seg_present->segtype->name);
 		return 0;
 	}
 


