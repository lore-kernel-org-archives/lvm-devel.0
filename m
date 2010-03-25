From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 02:40:09 -0000
Subject: LVM2/lib/metadata lv_manip.c pv_map.h
Message-ID: <20100325024009.6756.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 02:40:09

Modified files:
	lib/metadata   : lv_manip.c pv_map.h 

Log message:
	improve a few comments in last check-in

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.213&r2=1.214
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/lib/metadata/lv_manip.c	2010/03/25 02:31:49	1.213
+++ LVM2/lib/metadata/lv_manip.c	2010/03/25 02:40:09	1.214
@@ -929,7 +929,7 @@
 		return 1;
 
 	/*
-	 * Only used for cling and contiguous policies so its safe to say all
+	 * Only used for cling and contiguous policies so it's safe to say all
 	 * the available space is used.
 	 */
 	pvmatch->areas[s].pva = pvmatch->pva;
--- LVM2/lib/metadata/pv_map.h	2010/03/25 02:31:49	1.11
+++ LVM2/lib/metadata/pv_map.h	2010/03/25 02:40:09	1.12
@@ -39,7 +39,9 @@
  * an allocation attempt, track the maximum number of extents that may
  * need to be used as a particular parallel area.  Several of these
  * structs may reference the same pv_area, but 'used' may differ between
- * them.
+ * them.  The sum of all the 'used' variables referring to the same
+ * pv_area may not exceed that area's count, so we cannot allocate the
+ * same extents twice.
  */
 struct pv_area_used {
 	struct pv_area *pva;


