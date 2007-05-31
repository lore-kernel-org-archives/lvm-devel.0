From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 May 2007 14:19:57 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c
Message-ID: <20070531141957.25747.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-05-31 14:19:57

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 

Log message:
	Small fixes to pvdisplay --maps: 1) rename struct pv_segment vars from 'seg' to 'pvseg', 2) Change heading

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.622&r2=1.623
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2007/05/30 20:43:08	1.622
+++ LVM2/WHATS_NEW	2007/05/31 14:19:57	1.623
@@ -1,6 +1,6 @@
 Version 2.02.26 -
 =================================
-  Add --maps feature to pvdisplay, showing PE to LE mappings.
+  Add pvdisplay --maps implementation.
   Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.
   Fix vgrename man page to include UUID and be consistent with lvrename.
   Add (experimental) OpenAIS support to clvmd.
--- LVM2/lib/display/display.c	2007/05/30 20:43:09	1.71
+++ LVM2/lib/display/display.c	2007/05/31 14:19:57	1.72
@@ -260,26 +260,26 @@
 
 void pvdisplay_segments(struct physical_volume *pv)
 {
-	struct pv_segment *seg;
+	struct pv_segment *pvseg;
 
-	log_print("--- Segments ---");
+	log_print("--- Physical Segments ---");
 
-	list_iterate_items(seg, &pv->segments) {
-		if (seg->len == pv->pe_count)
+	list_iterate_items(pvseg, &pv->segments) {
+		if (pvseg->len == pv->pe_count)
 			continue;
 		log_print("Physical extent %u to %u:",
-			  seg->pe, seg->pe + seg->len - 1);
+			  pvseg->pe, pvseg->pe + pvseg->len - 1);
 
-		if (seg->lvseg) {
+		if (pvseg->lvseg) {
 			log_print("  Type\t\t%s",
-				  seg->lvseg->segtype->ops->name(seg->lvseg));
+				  pvseg->lvseg->segtype->ops->name(pvseg->lvseg));
 			log_print("  Logical volume\t%s%s/%s",
-				  seg->lvseg->lv->vg->cmd->dev_dir,
-				  seg->lvseg->lv->vg->name,
-				  seg->lvseg->lv->name);
+				  pvseg->lvseg->lv->vg->cmd->dev_dir,
+				  pvseg->lvseg->lv->vg->name,
+				  pvseg->lvseg->lv->name);
 			log_print("  Logical extents\t%d to %d",
-				  seg->lvseg->le, seg->lvseg->le +
-				  seg->lvseg->len - 1);
+				  pvseg->lvseg->le, pvseg->lvseg->le +
+				  pvseg->lvseg->len - 1);
 		} else
 			log_print("  FREE");
 	}


