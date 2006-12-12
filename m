From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Dec 2006 19:30:11 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20061212193011.25028.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-12-12 19:30:10

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix detection of smallest area in _alloc_parallel_area() for cling policy.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.518&r2=1.519
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/WHATS_NEW	2006/12/11 14:06:25	1.518
+++ LVM2/WHATS_NEW	2006/12/12 19:30:10	1.519
@@ -1,5 +1,6 @@
 Version 2.02.17 -
 ===================================
+  Fix detection of smallest area in _alloc_parallel_area() for cling policy.
   Add manpage entry for clvmd -T
   Fix gulm operation of clvmd, including a hang when doing lvchange -aey
   Fix hang in clvmd if a pre-command failed.
--- LVM2/lib/metadata/lv_manip.c	2006/10/30 16:10:55	1.112
+++ LVM2/lib/metadata/lv_manip.c	2006/12/12 19:30:10	1.113
@@ -628,17 +628,17 @@
 				struct pv_area **areas,
 				uint32_t *ix, struct pv_area *log_area)
 {
-	uint32_t area_len, smallest, remaining;
+	uint32_t area_len, remaining;
 	uint32_t s;
 	struct alloced_area *aa;
 
 	remaining = needed - *ix;
 	area_len = remaining / ah->area_multiple;
 
-	smallest = areas[ah->area_count - 1]->count;
-
-	if (area_len > smallest)
-		area_len = smallest;
+	/* Reduce area_len to the smallest of the areas */
+	for (s = 0; s < ah->area_count; s++)
+		if (area_len > areas[s]->count)
+			area_len = areas[s]->count;
 
 	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) *
 			      (ah->area_count + (log_area ? 1 : 0))))) {


