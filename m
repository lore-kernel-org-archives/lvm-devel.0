From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 31 Mar 2010 17:21:42 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20100331172142.32757.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-31 17:21:41

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h pv_manip.c 

Log message:
	Optimise PV segments search.
	
	The function find_peg_by_pe is incredibly inefficient
	for Pvs with many segments.
	
	In shiny future there should be binary (or interval) tree
	instead of sorted linked list (volunteers?).
	
	Anyway, for now, we can use dirty trick here to optimise this case:
	
	- Allocations are usually applied from the beginning
	of PV (we have no alloocation policy which allocates areas
	"backwards")
	
	- The only user of find_peg_by_pe is pv_split_segment()
	call. In *most* cases it need to split *last* PV segment.
	
	So if we search sorted pv segment list backwards, we
	hit the requested segment immediatelly.
	
	This patch applies this tiny change.
	(and saves >30% of processing time when >3000LVs segments are on one PV!)
	
	To discourage using this inefficient function from other code,
	it is moved to pv_manip.c and used static for now:-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1494&r2=1.1495
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.325&r2=1.326
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.200&r2=1.201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2010/03/31 17:20:44	1.1494
+++ LVM2/WHATS_NEW	2010/03/31 17:21:40	1.1495
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Optimise PV segments search for the most last segment search case.
   Remove vg_validate call when parsing cached metadata.
   Use hash table of LVs to speed up parsing of text metadata with many LVs.
   Fix two messages, add a whitespace and parentheses
--- LVM2/lib/metadata/metadata.c	2010/03/31 12:06:30	1.325
+++ LVM2/lib/metadata/metadata.c	2010/03/31 17:21:40	1.326
@@ -1799,18 +1799,6 @@
 	return NULL;
 }
 
-/* Find segment at a given physical extent in a PV */
-struct pv_segment *find_peg_by_pe(const struct physical_volume *pv, uint32_t pe)
-{
-	struct pv_segment *peg;
-
-	dm_list_iterate_items(peg, &pv->segments)
-		if (pe >= peg->pe && pe < peg->pe + peg->len)
-			return peg;
-
-	return NULL;
-}
-
 int vg_remove_mdas(struct volume_group *vg)
 {
 	struct metadata_area *mda;
--- LVM2/lib/metadata/metadata.h	2010/02/14 03:21:06	1.200
+++ LVM2/lib/metadata/metadata.h	2010/03/31 17:21:40	1.201
@@ -308,9 +308,6 @@
 /* Find LV segment containing given LE */
 struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le);
 
-/* Find PV segment containing given LE */
-struct pv_segment *find_peg_by_pe(const struct physical_volume *pv, uint32_t pe);
-
 /*
  * Remove a dev_dir if present.
  */
--- LVM2/lib/metadata/pv_manip.c	2008/11/03 22:14:29	1.22
+++ LVM2/lib/metadata/pv_manip.c	2010/03/31 17:21:40	1.23
@@ -78,6 +78,20 @@
 	return 1;
 }
 
+/* Find segment at a given physical extent in a PV */
+static struct pv_segment *find_peg_by_pe(const struct physical_volume *pv,
+					 uint32_t pe)
+{
+	struct pv_segment *pvseg;
+
+	/* search backwards to optimise mostly used last segment split */
+	dm_list_iterate_back_items(pvseg, &pv->segments)
+		if (pe >= pvseg->pe && pe < pvseg->pe + pvseg->len)
+			return pvseg;
+
+	return NULL;
+}
+
 /*
  * Split peg at given extent.
  * Second part is always deallocated.


