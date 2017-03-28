From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 28 Mar 2017 11:23:15 -0400
Subject: master - pre-release
Message-ID: <201703281523.v2SFNFx2020664@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=396377bc03a9f8a13f5d851306f7d2a622a1a74e
Commit:        396377bc03a9f8a13f5d851306f7d2a622a1a74e
Parent:        b9399f21489cb98a21ec08162ba9ac26e4b973c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 28 15:28:53 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 28 16:11:35 2017 +0100

pre-release

Removing some unused new lines and changing some incorrect "can't
release until this is fixed" comments.  Rename license.txt to make
it clear its merely an included file, not itself a licence.
---
 VERSION                   |    2 +-
 VERSION_DM                |    2 +-
 WHATS_NEW                 |   28 ++++++++--------
 WHATS_NEW_DM              |   17 +++++-----
 doc/license.txt           |   14 --------
 lib/metadata/raid_manip.c |   76 ++------------------------------------------
 lib/metadata/segtype.h    |    2 +-
 lib/metadata/thin_manip.c |    7 ++--
 libdm/libdm-deptree.c     |   24 +++----------
 tools/Makefile.in         |    6 ++--
 tools/license.inc         |   14 ++++++++
 tools/tools.h             |    1 -
 12 files changed, 57 insertions(+), 136 deletions(-)

diff --git a/VERSION b/VERSION
index 014ff40..668025a 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.169(2)-git (2016-11-30)
+2.02.169(2)-git (2017-03-28)
diff --git a/VERSION_DM b/VERSION_DM
index 6734686..50aa874 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.138-git (2016-11-30)
+1.02.138-git (2017-03-28)
diff --git a/WHATS_NEW b/WHATS_NEW
index 6c66631..bebbb6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,17 +1,17 @@
-Version 2.02.169 - 
-=====================================
-  man-generator - escape '-'
-  Add configuration command line to 'lvm version' output.
-  Adjust to misordered raid parameters
-  Conditionally reject raid convert to striped/raid0* after reshape
-  Ensure raid6 upconversion restrictions
-  Adjust mirror+raid DSOs to aforementioned lvconvert --repair
+Version 2.02.169 - 28th March 2017
+==================================
+  Automatically decide whether '-' in a man page is a hyphen or a minus sign.
+  Add build-time configuration command line to 'lvm version' output.
+  Handle known table line parameter order change in specific raid target vsns.
+  Conditionally reject raid convert to striped/raid0* after reshape.
+  Ensure raid6 upconversion restrictions.
+  Adjust mirror & raid dmeventd plugins for new lvconvert --repair behaviour.
   Disable lvmetad when lvconvert --repair is run.
   Remove obsolete lvmchange binary - convert to built-in command.
-  Lvdisplay [-m] shows more informations for cached volumes.
+  Show more information for cached volumes in lvdisplay [-m].
   Add option for lvcreate/lvconvert --cachemetadataformat auto|1|2.
   Support cache segment with configurable metadata format.
-  Add allocation/cache_metadata_format profilable setttings.
+  Add allocation/cache_metadata_format profilable settings.
   Use function cache_set_params() for both lvcreate and lvconvert.
   Skip rounding on cache chunk size boudary when create cache LV.
   Improve cache_set_params support for chunk_size selection.
@@ -21,7 +21,7 @@ Version 2.02.169 -
   Support conversion of raid type, stripesize and number of disks
   Reject writemostly/writebehind in lvchange during resynchronization.
   Deactivate active origin first before removal for improved workflow.
-  Fix regression of accepting options --type and -m with lvresize (2.02.158).
+  Fix regression of accepting both --type and -m with lvresize. (2.02.158)
   Add lvconvert --swapmetadata, new specific way to swap pool metadata LVs.
   Add lvconvert --startpoll, new specific way to start polling conversions.
   Add lvconvert --mergethin, new specific way to merge thin snapshots.
@@ -34,9 +34,9 @@ Version 2.02.169 -
   Match every command run to one command definition.
   Specify every allowed command definition/syntax in command-lines.in.
   Add extra memory page when limiting pthread stack size in clvmd.
-  Support striped/raid0* <-> raid10_near conversions
-  Support shrinking of RaidLvs
-  Support region size changes on existing RaidLVs
+  Support striped/raid0* <-> raid10_near conversions.
+  Support shrinking of RaidLVs.
+  Support region size changes on existing RaidLVs.
   Avoid parallel usage of cpg_mcast_joined() in clvmd with corosync.
   Support raid6_{ls,rs,la,ra}_6 segment types and conversions from/to it.
   Support raid6_n_6 segment type and conversions from/to it.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 91fd8f9..cee1329 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,23 +1,24 @@
-Version 1.02.138 - 
-=====================================
+Version 1.02.138 - 28th March 2017
+==================================
+  Support additional raid5/6 configurations.
   Provide dm_tree_node_add_cache_target at base compatible symbol.
   Support DM_CACHE_FEATURE_METADATA2, new cache metadata format 2.
   Improve code to handle mode mask for cache nodes.
   Cache status check for passthrough also require trailing space.
   Add extra memory page when limiting pthread stack size in dmeventd.
   Avoids immediate resume when preloaded device is smaller.
-  Do not suppress kernel key description in dmsetup table output.
+  Do not suppress kernel key description in dmsetup table output for dm-crypt.
   Support configurable command executed from dmeventd thin plugin.
   Support new R|r human readable units output format.
   Thin dmeventd plugin reacts faster on lvextend failure path with umount.
   Add dm_stats_bind_from_fd() to bind a stats handle from a file descriptor.
   Do not try call callback when reverting activation on error path.
-  Fix file mapping for extents with physically adjacent extents.
+  Fix file mapping for extents with physically adjacent extents in dmstats.
   Validation vsnprintf result in runtime translate of dm_log (1.02.136).
-  Separate filemap extent allocation from region table.
-  Fix segmentation fault when filemap region creation fails.
-  Fix performance of region cleanup for failed filemap creation.
-  Fix very slow region deletion with many regions.
+  Separate filemap extent allocation from region table in dmstats.
+  Fix segmentation fault when filemap region creation fails in dmstats.
+  Fix performance of region cleanup for failed filemap creation in dmstats.
+  Fix very slow region deletion with many regions in dmstats.
 
 Version 1.02.137 - 30th November 2016
 =====================================
diff --git a/doc/license.txt b/doc/license.txt
deleted file mode 100644
index 5ba3e66..0000000
--- a/doc/license.txt
+++ /dev/null
@@ -1,14 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 018e36d..4d20639 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2305,7 +2305,8 @@ static int _raid_reshape(struct logical_volume *lv,
 	} if (!_vg_write_commit_backup(lv->vg))
 		return 0;
 
-	return 1; // force_repair ? _lv_cond_repair(lv) : 1;
+	return 1; 
+	/* FIXME force_repair ? _lv_cond_repair(lv) : 1; */
 }
 
 /*
@@ -2325,6 +2326,8 @@ static int _raid_reshape(struct logical_volume *lv,
  * 1 -> allowed reshape request
  * 2 -> prohibited reshape request
  * 3 -> allowed region size change request
+ *
+ * FIXME Use alternative mechanism - separate parameter or enum.
  */
 static int _reshape_requested(const struct logical_volume *lv, const struct segment_type *segtype,
 			      const int data_copies, const uint32_t region_size,
@@ -2364,33 +2367,6 @@ static int _reshape_requested(const struct logical_volume *lv, const struct segm
 			  display_lvname(lv));
 		return 2;
 	}
-#if 0
-	if ((_lv_is_duplicating(lv) || lv_is_duplicated(lv)) &&
-	    ((seg_is_raid1(seg) ? 0 : (stripes != _data_rimages_count(seg, seg->area_count))) ||
-	     data_copies != seg->data_copies))
-		goto err;
-	if ((!seg_is_striped(seg) && segtype_is_raid10_far(segtype)) ||
-	    (seg_is_raid10_far(seg) && !segtype_is_striped(segtype))) {
-		if (data_copies == seg->data_copies &&
-		    region_size == seg->region_size) {
-			log_error("Can't convert %sraid10_far.",
-				  seg_is_raid10_far(seg) ? "" : "to ");
-			goto err;
-		}
-	}
-
-	if (seg_is_raid10_far(seg)) {
-		if (stripes != _data_rimages_count(seg, seg->area_count)) {
-			log_error("Can't change stripes in raid10_far.");
-			goto err;
-		}
-
-		if (stripe_size != seg->stripe_size) {
-			log_error("Can't change stripe size in raid10_far.");
-			goto err;
-		}
-	}
-#endif
 
 	if (seg_is_any_raid10(seg) && seg->area_count > 2 &&
 	    stripes && stripes < seg->area_count - seg->segtype->parity_devs) {
@@ -2401,46 +2377,8 @@ static int _reshape_requested(const struct logical_volume *lv, const struct segm
 	if (data_copies != seg->data_copies) {
 		if (seg_is_raid10_near(seg))
 			return 0;
-#if 0
-		if (seg_is_raid10_far(seg))
-			return segtype_is_raid10_far(segtype) ? 1 : 0;
-
-		if (seg_is_raid10_offset(seg)) {
-			log_error("Can't change number of data copies on %s LV %s.",
-				  lvseg_name(seg), display_lvname(lv));
-			goto err;
-		}
-#endif
 	}
 
-#if 0
-	/* raid10_{near,offset} case */
-	if ((seg_is_raid10_near(seg) && segtype_is_raid10_offset(segtype)) ||
-	    (seg_is_raid10_offset(seg) && segtype_is_raid10_near(segtype))) {
-		if (stripes >= seg->area_count)
-			return 1;
-
-		goto err;
-	}
-
-	/*
-	 * raid10_far is not reshapable in MD at all;
-	 * lvm/dm adds reshape capability to add/remove data_copies
-	 */
-	if (seg_is_raid10_far(seg) && segtype_is_raid10_far(segtype)) {
-		if (stripes && stripes == seg->area_count &&
-		    data_copies > 1 &&
-		    data_copies <= seg->area_count &&
-		    data_copies != seg->data_copies)
-			return 1;
-
-		goto err;
-
-	} else if (seg_is_any_raid10(seg) && segtype_is_any_raid10(segtype) &&
-		   data_copies > 1 && data_copies != seg->data_copies)
-		goto err;
-#endif
-
 	/* Change layout (e.g. raid5_ls -> raid5_ra) keeping # of stripes */
 	if (seg->segtype != segtype) {
 		if (stripes && stripes != _data_rimages_count(seg, seg->area_count))
@@ -2459,12 +2397,6 @@ static int _reshape_requested(const struct logical_volume *lv, const struct segm
 	return (stripes || stripe_size) ? 1 : 0;
 
 err:
-#if 0
-	if (lv_is_duplicated(lv))
-		log_error("Conversion of duplicating sub LV %s rejected.", display_lvname(lv));
-	else
-		log_error("Use \"lvconvert --duplicate --type %s ... %s.", segtype->name, display_lvname(lv));
-#endif
 	return 2;
 }
 
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 421c6f9..0eea6e6 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -141,7 +141,7 @@ struct dev_manager;
 #define segtype_is_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
 #define segtype_is_raid10_near(segtype)	segtype_is_raid10(segtype)
 /* FIXME: once raid10_offset supported */
-#define segtype_is_raid10_offset(segtype)	0 // ((segtype)->flags & SEG_RAID10_OFFSET ? 1 : 0)
+#define segtype_is_raid10_offset(segtype)	0 /* FIXME ((segtype)->flags & SEG_RAID10_OFFSET ? 1 : 0 */
 #define segtype_is_raid_with_meta(segtype)	(segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
 #define segtype_is_striped_raid(segtype)        (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))
 #define segtype_is_reshapable_raid(segtype)     ((segtype_is_striped_raid(segtype) && !segtype_is_any_raid0(segtype)) || segtype_is_raid10_near(segtype) || segtype_is_raid10_offset(segtype))
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 71f9cc0..f9cd3d0 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -100,9 +100,10 @@ int attach_thin_external_origin(struct lv_segment *seg,
 			external_lv->status &= ~LVM_WRITE;
 		}
 
-		// TODO: should we mark even origin read-only ?
-		//if (lv_is_cache(external_lv)) /* read-only corigin of cache LV */
-		//	seg_lv(first_seg(external_lv), 0)->status &= ~LVM_WRITE;
+		/* FIXME Mark origin read-only?
+		if (lv_is_cache(external_lv)) // read-only corigin of cache LV
+			seg_lv(first_seg(external_lv), 0)->status &= ~LVM_WRITE;
+		 */
 	}
 
 	return 1;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 3551592..a25d4c3 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1734,9 +1734,11 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 		    !child->callback(child, DM_NODE_CALLBACK_DEACTIVATED,
 				     child->callback_data))
 			stack;
-			// FIXME: We need to let lvremove pass,
-			// so for now deactivation ignores check result
-			//r = 0; // FIXME: _node_clear_table() without callback ?
+			/* FIXME Deactivation must currently ignore failure
+			 * here so that lvremove can continue: we need an
+			 * alternative way to handle this state without 
+			 * setting r=0.  Or better, skip calling thin_check
+			 * entirely if the device is about to be removed. */
 
 		if (dm_tree_node_num_children(child, 0) &&
 		    !_dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len, level + 1))
@@ -2457,17 +2459,8 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	type = seg->type;
 	if (type == SEG_RAID0_META)
 		type = SEG_RAID0;
-#if 0
-	/* Kernel only expects "raid10", not "raid10_{far,offset}" */
-	else if (type == SEG_RAID10_FAR ||
-		 type == SEG_RAID10_OFFSET) {
-		param_count += 2;
-		type = SEG_RAID10_NEAR;
-	}
-#endif
 
 	EMIT_PARAMS(pos, "%s %d %u",
-		    // type == SEG_RAID10_NEAR ? "raid10" : _dm_segtypes[type].target,
 		    type == SEG_RAID10 ? "raid10" : _dm_segtypes[type].target,
 		    param_count, seg->stripe_size);
 
@@ -2508,12 +2501,7 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 
 		if (seg->data_copies > 1 && type == SEG_RAID10)
 			EMIT_PARAMS(pos, " raid10_copies %u", seg->data_copies);
-#if 0
-	if (seg->type == SEG_RAID10_FAR)
-		EMIT_PARAMS(pos, " raid10_format far");
-	else if (seg->type == SEG_RAID10_OFFSET)
-		EMIT_PARAMS(pos, " raid10_format offset");
-#endif
+
 		if (seg->delta_disks)
 			EMIT_PARAMS(pos, " delta_disks %d", seg->delta_disks);
 
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 8ea6801..3b7b63d 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -186,7 +186,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 command-count.h: $(srcdir)/command-lines.in Makefile
 	set -o pipefail && \
-	( cat $(top_srcdir)/doc/license.txt && \
+	( cat $(top_srcdir)/tools/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo -n "#define COMMAND_COUNT " && \
 	  $(GREP) '^ID:' $(srcdir)/command-lines.in | $(WC) -l \
@@ -194,7 +194,7 @@ command-count.h: $(srcdir)/command-lines.in Makefile
 
 cmds.h: $(srcdir)/command-lines.in Makefile
 	set -o pipefail && \
-	( cat $(top_srcdir)/doc/license.txt && \
+	( cat $(top_srcdir)/tools/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo "cmd(CMD_NONE, none)" && \
 	  $(GREP) '^ID:' $(srcdir)/command-lines.in | $(SORT) -u | $(AWK) '{print "cmd(" $$2 "_CMD, " $$2 ")"}' && \
@@ -203,7 +203,7 @@ cmds.h: $(srcdir)/command-lines.in Makefile
 
 command-lines-input.h: $(srcdir)/command-lines.in Makefile
 	set -o pipefail && \
-	( cat $(top_srcdir)/doc/license.txt && \
+	( cat $(top_srcdir)/tools/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo -en "const char _command_input[] =\n\n\"" && \
 	  $(EGREP) -v '^#|\-\-\-|^$$' $(srcdir)/command-lines.in | $(AWK) 'BEGIN {ORS = "\\n\"\n\""} //' && \
diff --git a/tools/license.inc b/tools/license.inc
new file mode 100644
index 0000000..5ba3e66
--- /dev/null
+++ b/tools/license.inc
@@ -0,0 +1,14 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
diff --git a/tools/tools.h b/tools/tools.h
index 10d7450..9543147 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -105,7 +105,6 @@ struct arg_values {
 	uint64_t ui64_value;
 	sign_t sign;
 	percent_type_t percent;
-/*	void *ptr; // Currently not used. */
 };
 
 struct arg_value_group_list {


