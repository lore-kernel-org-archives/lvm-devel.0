From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 26 Jul 2012 17:20:45 -0500
Subject: [PATCH] First cut at RAID10 support
Message-ID: <1343341245.28351.2.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With this patch, I can create a RAID10 LV and increase it's size
(lvresize).  I've not tested much beyond that.  Man page updates are not
done yet either.  Looking for early objections...

 brassow

Index: lvm2/lib/raid/raid.c
===================================================================
--- lvm2.orig/lib/raid/raid.c
+++ lvm2/lib/raid/raid.c
@@ -379,6 +379,20 @@ static struct segment_type *_init_raid1_
 	return segtype;
 }
 
+static struct segment_type *_init_raid10_segtype(struct cmd_context *cmd)
+{
+	struct segment_type *segtype;
+
+	segtype = _init_raid_segtype(cmd, "raid10");
+	if (!segtype)
+		return NULL;
+
+	segtype->flags |= SEG_AREAS_MIRRORED;
+	segtype->parity_devs = 0;
+
+	return segtype;
+}
+
 static struct segment_type *_init_raid4_segtype(struct cmd_context *cmd)
 {
 	return _init_raid_segtype(cmd, "raid4");
@@ -441,6 +455,7 @@ int init_multiple_segtypes(struct cmd_co
 	unsigned i = 0;
 	struct segment_type *(*raid_segtype_fn[])(struct cmd_context *) =  {
 		_init_raid1_segtype,
+		_init_raid10_segtype,
 		_init_raid4_segtype,
 		_init_raid5_segtype,
 		_init_raid5_la_segtype,
Index: lvm2/tools/lvcreate.c
===================================================================
--- lvm2.orig/tools/lvcreate.c
+++ lvm2/tools/lvcreate.c
@@ -679,7 +679,12 @@ static int _lvcreate_params(struct lvcre
 
 	/* Set default segtype */
 	if (arg_count(cmd, mirrors_ARG))
-		segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+		if (arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ?
+				   stripes_long_ARG : stripes_ARG, 1) > 1) {
+			segtype_str = "raid10";
+		} else {
+			segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+		}
 	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
 		segtype_str = "thin";
 	else
@@ -712,7 +717,7 @@ static int _lvcreate_params(struct lvcre
 
 	lp->mirrors = 1;
 
-	/* Default to 2 mirrored areas if '--type mirror|raid1' */
+	/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
 	if (segtype_is_mirrored(lp->segtype))
 		lp->mirrors = 2;
 
@@ -725,6 +730,18 @@ static int _lvcreate_params(struct lvcre
 			}
 			log_print("Redundant mirrors argument: default is 0");
 		}
+
+		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, "raid10")) {
+			/*
+			 * FIXME: When this RAID10 is no longer limited to
+			 *        2-way mirror, 'lv_mirror_count()'
+			 *        must also change for RAID10.
+			 */
+			log_error("RAID10 currently supports "
+				  "only 2-way mirroring (i.e. '-m 1')");
+			return 0;
+		}
+
 		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Mirrors argument may not be negative");
 			return 0;
@@ -764,6 +781,16 @@ static int _lvcreate_params(struct lvcre
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
+	} else if (!strcmp(lp->segtype->name, "raid10")) {
+		uint32_t maj, min, patchlevel;
+		if (!target_version("raid", &maj, &min, &patchlevel)) {
+			log_error("Failed to determine version of RAID kernel module");
+			return 0;
+		}
+		if ((maj != 1) || (min < 3)) {
+			log_error("RAID module does not support RAID10");
+			return 0;
+		}
 	}
 
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
Index: lvm2/libdm/libdm-deptree.c
===================================================================
--- lvm2.orig/libdm/libdm-deptree.c
+++ lvm2/libdm/libdm-deptree.c
@@ -42,6 +42,7 @@ enum {
 	SEG_THIN_POOL,
 	SEG_THIN,
 	SEG_RAID1,
+	SEG_RAID10,
 	SEG_RAID4,
 	SEG_RAID5_LA,
 	SEG_RAID5_RA,
@@ -73,6 +74,7 @@ struct {
 	{ SEG_THIN_POOL, "thin-pool"},
 	{ SEG_THIN, "thin"},
 	{ SEG_RAID1, "raid1"},
+	{ SEG_RAID10, "raid10"},
 	{ SEG_RAID4, "raid4"},
 	{ SEG_RAID5_LA, "raid5_la"},
 	{ SEG_RAID5_RA, "raid5_ra"},
@@ -1913,6 +1915,7 @@ static int _emit_areas_line(struct dm_ta
 			}
 			break;
 		case SEG_RAID1:
+		case SEG_RAID10:
 		case SEG_RAID4:
 		case SEG_RAID5_LA:
 		case SEG_RAID5_RA:
@@ -2266,6 +2269,7 @@ static int _emit_segment_line(struct dm_
 			    seg->iv_offset : *seg_start);
 		break;
 	case SEG_RAID1:
+	case SEG_RAID10:
 	case SEG_RAID4:
 	case SEG_RAID5_LA:
 	case SEG_RAID5_RA:
Index: lvm2/lib/metadata/lv.c
===================================================================
--- lvm2.orig/lib/metadata/lv.c
+++ lvm2/lib/metadata/lv.c
@@ -477,10 +477,10 @@ char *lv_attr_dup(struct dm_pool *mem, c
 
 	if (lv_is_thin_type(lv))
 		repstr[6] = 't';
-	else if (lv_is_mirror_type(lv))
-		repstr[6] = 'm';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';
+	else if (lv_is_mirror_type(lv))
+		repstr[6] = 'm';
 	else if (lv_is_cow(lv) || lv_is_origin(lv))
 		repstr[6] = 's';
 	else if (lv_has_unknown_segments(lv))
Index: lvm2/lib/metadata/lv_manip.c
===================================================================
--- lvm2.orig/lib/metadata/lv_manip.c
+++ lvm2/lib/metadata/lv_manip.c
@@ -710,6 +710,14 @@ static uint32_t _calc_area_multiple(cons
 		return area_count - segtype->parity_devs;
 	}
 
+	/* RAID10 - only has 2-way mirror right now */
+	if (!strcmp(segtype->name, "raid10")) {
+		// FIXME: I'd like the 'stripes' arg always given
+		if (!stripes)
+			return area_count / 2;
+		return stripes;
+	}
+
 	/* Mirrored stripes */
 	if (stripes)
 		return stripes;
Index: lvm2/lib/metadata/mirror.c
===================================================================
--- lvm2.orig/lib/metadata/mirror.c
+++ lvm2/lib/metadata/mirror.c
@@ -115,6 +115,10 @@ uint32_t lv_mirror_count(const struct lo
 
 	seg = first_seg(lv);
 
+	/* FIXME: RAID10 only supports 2 copies right now */
+	if (!strcmp(seg->segtype->name, "raid10"))
+		return 2;
+
 	if (lv->status & PVMOVE)
 		return seg->area_count;
 
Index: lvm2/tools/lvresize.c
===================================================================
--- lvm2.orig/tools/lvresize.c
+++ lvm2/tools/lvresize.c
@@ -578,6 +578,7 @@ static int _lvresize(struct cmd_context
 				seg_mirrors = 0;
 			break;
 		}
+
 		if (!arg_count(cmd, mirrors_ARG) && seg_mirrors) {
 			log_print("Extending %" PRIu32 " mirror images.",
 				  seg_mirrors);
@@ -588,18 +589,26 @@ static int _lvresize(struct cmd_context
 			log_error("Cannot vary number of mirrors in LV yet.");
 			return EINVALID_CMD_LINE;
 		}
+
+		if (seg_mirrors && !strcmp(mirr_seg->segtype->name, "raid10")) {
+			lp->stripes = mirr_seg->area_count / seg_mirrors;
+			lp->stripe_size = mirr_seg->stripe_size;
+		}
 	}
 
 	/* If extending, find stripes, stripesize & size of last segment */
 	if ((lp->extents > lv->le_count) &&
-	    !(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size))) {
+	    !(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size)) &&
+	    strcmp(mirr_seg->segtype->name, "raid10")) {
 		/* FIXME Don't assume mirror seg will always be AREA_LV */
 		/* FIXME We will need to support resize for metadata LV as well,
 		 *       and data LV could be any type (i.e. mirror)) */
 		dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments :
 				      lv_is_thin_pool(lv) ? &seg_lv(first_seg(lv), 0)->segments : &lv->segments) {
+			/* Allow through "striped" and RAID 4/5/6/10 */
 			if (!seg_is_striped(seg) &&
-			    (!seg_is_raid(seg) || seg_is_mirrored(seg)))
+			    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
+			    strcmp(seg->segtype->name, "raid10"))
 				continue;
 
 			sz = seg->stripe_size;



