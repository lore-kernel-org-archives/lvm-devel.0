From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 2 Mar 2010 21:56:15 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20100302215615.23792.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-03-02 21:56:15

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Handle a misaligned device that reports a -1 alignment_offset.
	
	The kernel's blk_stack_limits() function may flag a device as
	'misaligned'.  If it does the alignment_offset will be -1.
	
	Update set_pe_align_offset() to accommodate this corner case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1441&r2=1.1442
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.317&r2=1.318

--- LVM2/WHATS_NEW	2010/03/01 20:00:20	1.1441
+++ LVM2/WHATS_NEW	2010/03/02 21:56:14	1.1442
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Handle a misaligned device that reports a -1 alignment_offset.
   Extend core allocation code in preparation for mirrored log areas.
   Rewrite clvmd init script.
   Remove lvs_in_vg_activated_by_uuid_only call.
--- LVM2/lib/metadata/metadata.c	2010/02/24 18:15:57	1.317
+++ LVM2/lib/metadata/metadata.c	2010/03/02 21:56:14	1.318
@@ -123,11 +123,14 @@
 
 	if (find_config_tree_bool(pv->fmt->cmd,
 				  "devices/data_alignment_offset_detection",
-				  DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION))
-		pv->pe_align_offset =
-			MAX(pv->pe_align_offset,
-			    dev_alignment_offset(pv->fmt->cmd->sysfs_dir,
-						 pv->dev));
+				  DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION)) {
+		int align_offset = dev_alignment_offset(pv->fmt->cmd->sysfs_dir,
+							pv->dev);
+		/* must handle a -1 alignment_offset; means dev is misaligned */
+		if (align_offset < 0)
+			align_offset = 0;
+		pv->pe_align_offset = MAX(pv->pe_align_offset, align_offset);
+	}
 
 	log_very_verbose("%s: Setting PE alignment offset to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align_offset);


