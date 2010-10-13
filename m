From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Oct 2010 21:26:39 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20101013212639.22626.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-10-13 21:26:38

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/metadata   : segtype.h 
	lib/snapshot   : snapshot.c 
	man            : lvconvert.8.in 
	tools          : lvconvert.c 

Log message:
	Convey need for snapshot-merge target in lvconvert error message and man
	page.
	
	Add ->target_name to segtype_handler to allow a more specific target
	name to be returned based on the state of the segment.
	
	Result of trying to merge a snapshot using a kernel that doesn't have
	the snapshot-merge target:
	
	Before:
	# lvconvert --merge vg/snap
	Can't expand LV lv: snapshot target support missing from kernel?
	Failed to suspend origin lv
	
	After:
	# lvconvert --merge vg/snap
	Can't process LV lv: snapshot-merge target support missing from kernel?
	Failed to suspend origin lv
	Unable to merge LV "snap" into it's origin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1760&r2=1.1761
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.202&r2=1.203
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/WHATS_NEW	2010/10/13 15:50:34	1.1760
+++ LVM2/WHATS_NEW	2010/10/13 21:26:37	1.1761
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Convey need for snapshot-merge target in lvconvert error message and man page.
   Add "devices/disable_after_error_count" to lvm.conf.
   Give correct error message when creating a too-small snapshot.
   Implement vgextend --restoremissing.
--- LVM2/lib/activate/dev_manager.c	2010/08/26 14:21:51	1.202
+++ LVM2/lib/activate/dev_manager.c	2010/10/13 21:26:37	1.203
@@ -1350,19 +1350,23 @@
 	uint32_t s;
 	struct dm_list *snh;
 	struct lv_segment *seg_present;
+	const char *target_name;
 
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_cow(seg->lv) ? : seg;
+	target_name = (seg_present->segtype->ops->target_name ?
+		       seg_present->segtype->ops->target_name(seg_present) :
+		       seg_present->segtype->name);
 
 	log_debug("Checking kernel supports %s segment type for %s%s%s",
-		  seg_present->segtype->name, seg->lv->name,
+		  target_name, seg->lv->name,
 		  layer ? "-" : "", layer ? : "");
 
 	if (seg_present->segtype->ops->target_present &&
 	    !seg_present->segtype->ops->target_present(seg_present->lv->vg->cmd,
 						       seg_present, NULL)) {
-		log_error("Can't expand LV %s: %s target support missing "
-			  "from kernel?", seg->lv->name, seg_present->segtype->name);
+		log_error("Can't process LV %s: %s target support missing "
+			  "from kernel?", seg->lv->name, target_name);
 		return 0;
 	}
 
--- LVM2/lib/metadata/segtype.h	2010/05/24 15:32:21	1.30
+++ LVM2/lib/metadata/segtype.h	2010/10/13 21:26:37	1.31
@@ -66,6 +66,7 @@
 
 struct segtype_handler {
 	const char *(*name) (const struct lv_segment * seg);
+	const char *(*target_name) (const struct lv_segment * seg);
 	void (*display) (const struct lv_segment * seg);
 	int (*text_export) (const struct lv_segment * seg,
 			    struct formatter * f);
--- LVM2/lib/snapshot/snapshot.c	2010/08/17 01:16:41	1.49
+++ LVM2/lib/snapshot/snapshot.c	2010/10/13 21:26:37	1.50
@@ -28,6 +28,14 @@
 	return seg->segtype->name;
 }
 
+static const char *_snap_target_name(const struct lv_segment *seg)
+{
+	if (seg->status & MERGING)
+		return "snapshot-merge";
+
+	return _snap_name(seg);
+}
+
 static int _snap_text_import(struct lv_segment *seg, const struct config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
@@ -217,6 +225,7 @@
 
 static struct segtype_handler _snapshot_ops = {
 	.name = _snap_name,
+	.target_name = _snap_target_name,
 	.text_import = _snap_text_import,
 	.text_export = _snap_text_export,
 	.target_status_compatible = _snap_target_status_compatible,
--- LVM2/man/lvconvert.8.in	2010/04/13 16:13:08	1.17
+++ LVM2/man/lvconvert.8.in	2010/10/13 21:26:38	1.18
@@ -135,8 +135,10 @@
 If the volume is read-only the snapshot will not be zeroed.
 .TP
 .I \-\-merge
-Merges a snapshot into its origin volume. If both the origin and snapshot volume
-are not open the merge will start immediately.  Otherwise, the merge will start
+Merges a snapshot into its origin volume.  To check if your kernel
+supports this feature, look for 'snapshot-merge' in the output
+of 'dmsetup targets'.  If both the origin and snapshot volume are not
+open the merge will start immediately.  Otherwise, the merge will start
 the first time either the origin or snapshot are activated and both are closed.
 Merging a snapshot into an origin that cannot be closed, for example a root
 filesystem, is deferred until the next time the origin volume is activated.
--- LVM2/tools/lvconvert.c	2010/10/12 16:41:18	1.147
+++ LVM2/tools/lvconvert.c	2010/10/13 21:26:38	1.148
@@ -1563,7 +1563,7 @@
 			return ECMD_FAILED;
 		}
 		if (!lvconvert_merge(cmd, lv, lp)) {
-			stack;
+			log_error("Unable to merge LV \"%s\" into it's origin.", lv->name);
 			return ECMD_FAILED;
 		}
 	} else if (lp->snapshot) {


