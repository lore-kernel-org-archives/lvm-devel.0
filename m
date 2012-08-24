From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 24 Aug 2012 20:37:32 +0000 (UTC)
Subject: master - RAID: Add support for RAID10
Message-ID: <20120824203732.1B20FA0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4047e4dfb16175daec348bf44032c02181bd4c70
Commit:        4047e4dfb16175daec348bf44032c02181bd4c70
Parent:        99d1e264a87eb256debe2eaa02d9fc4e2b08c815
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 24 15:34:19 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Aug 24 15:34:19 2012 -0500

RAID:  Add support for RAID10

This patch adds support for RAID10.  It is not the default at this
stage.  The user needs to specify '--type raid10' if they would like
RAID10 instead of stacked mirror over stripe.
---
 WHATS_NEW                    |    1 +
 lib/metadata/lv.c            |    4 +-
 lib/metadata/lv_manip.c      |    8 +++
 lib/metadata/mirror.c        |    4 ++
 lib/metadata/raid_manip.c    |   18 +++++++
 lib/raid/raid.c              |   15 ++++++
 libdm/libdm-deptree.c        |    4 ++
 test/shell/lvconvert-raid.sh |  109 +++++++++++++++++++++++++++++++++++++++++-
 test/shell/lvcreate-raid.sh  |   21 ++++++++-
 tools/lvcreate.c             |   28 ++++++++++-
 tools/lvresize.c             |   13 ++++-
 11 files changed, 218 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9bd1739..c7d5f54 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98
 =================================
+  Add RAID10 support.
   Reuse _reload_lv() in more lvconvert functions.
   Fix dereference of NULL in lvmetad error path logging.
   Fix buffer memory leak in lvmetad logging.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index bb6043d..003e18d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -476,10 +476,10 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
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
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 51abae0..59e1429 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -710,6 +710,14 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
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
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index ac885d6..e3662c1 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -114,6 +114,10 @@ uint32_t lv_mirror_count(const struct logical_volume *lv)
 
 	seg = first_seg(lv);
 
+	/* FIXME: RAID10 only supports 2 copies right now */
+	if (!strcmp(seg->segtype->name, "raid10"))
+		return 2;
+
 	if (lv->status & PVMOVE)
 		return seg->area_count;
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c86bb9a..0d4640f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1620,6 +1620,24 @@ int lv_raid_replace(struct logical_volume *lv,
 			  raid_seg->segtype->parity_devs,
 			  raid_seg->segtype->name, lv->vg->name, lv->name);
 		return 0;
+	} else if (!strcmp(raid_seg->segtype->name, "raid10")) {
+		uint32_t i, rebuilds_per_group = 0;
+		/* FIXME: We only support 2-way mirrors in RAID10 currently */
+		uint32_t copies = 2;
+
+		for (i = 0; i < raid_seg->area_count * copies; i++) {
+			s = i % raid_seg->area_count;
+			if (!(i % copies))
+				rebuilds_per_group = 0;
+			if (_lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
+			    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
+				rebuilds_per_group++;
+			if (rebuilds_per_group >= copies) {
+				log_error("Unable to replace all the devices "
+					  "in a RAID10 mirror group.");
+				return 0;
+			}
+		}
 	}
 
 	/*
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 097d36f..78fe074 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -379,6 +379,20 @@ static struct segment_type *_init_raid1_segtype(struct cmd_context *cmd)
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
@@ -441,6 +455,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 	unsigned i = 0;
 	struct segment_type *(*raid_segtype_fn[])(struct cmd_context *) =  {
 		_init_raid1_segtype,
+		_init_raid10_segtype,
 		_init_raid4_segtype,
 		_init_raid5_segtype,
 		_init_raid5_la_segtype,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 28d1153..f675d0d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -41,6 +41,7 @@ enum {
 	SEG_THIN_POOL,
 	SEG_THIN,
 	SEG_RAID1,
+	SEG_RAID10,
 	SEG_RAID4,
 	SEG_RAID5_LA,
 	SEG_RAID5_RA,
@@ -72,6 +73,7 @@ struct {
 	{ SEG_THIN_POOL, "thin-pool"},
 	{ SEG_THIN, "thin"},
 	{ SEG_RAID1, "raid1"},
+	{ SEG_RAID10, "raid10"},
 	{ SEG_RAID4, "raid4"},
 	{ SEG_RAID5_LA, "raid5_la"},
 	{ SEG_RAID5_RA, "raid5_ra"},
@@ -1912,6 +1914,7 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 			}
 			break;
 		case SEG_RAID1:
+		case SEG_RAID10:
 		case SEG_RAID4:
 		case SEG_RAID5_LA:
 		case SEG_RAID5_RA:
@@ -2265,6 +2268,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			    seg->iv_offset : *seg_start);
 		break;
 	case SEG_RAID1:
+	case SEG_RAID10:
 	case SEG_RAID4:
 	case SEG_RAID5_LA:
 	case SEG_RAID5_RA:
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index c63c141..c62aee5 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -11,12 +11,23 @@
 
 . lib/test
 
+get_image_pvs() {
+	local d
+	local images=""
+
+	for d in `ls /dev/mapper/${1}-${2}_?image_*`; do
+		images="$images `basename $d | sed s:-:/:`"
+	done
+	lvs --noheadings -a -o devices $images | sed s/\(.\)//
+}
+
 ########################################################
 # MAIN
 ########################################################
 aux target_at_least dm-raid 1 1 0 || skip
 
-aux prepare_pvs 5 80
+# 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
+aux prepare_pvs 9 80
 vgcreate -c n -s 256k $vg $(cat DEVICES)
 
 ###########################################
@@ -132,3 +143,99 @@ for i in 1 2 3 ; do
 	lvconvert --type raid1 $vg/$lv1
 	lvremove -ff $vg
 done
+
+###########################################
+# Device Replacement Testing
+###########################################
+# RAID1: Replace up to n-1 devices - trying different combinations
+# Test for 2-way to 4-way RAID1 LVs
+for i in {1..3}; do
+	lvcreate --type raid1 -m $i -l 2 -n $lv1 $vg
+
+	for j in $(seq $(($i + 1))); do # The number of devs to replace at once
+	for o in $(seq 0 $i); do        # The offset into the device list
+		replace=""
+
+		devices=( $(get_image_pvs $vg $lv1) )
+
+		for k in $(seq $j); do
+			index=$((($k + $o) % ($i + 1)))
+			replace="$replace --replace ${devices[$index]}"
+		done
+		aux wait_for_sync $vg $lv1
+
+		if [ $j -ge $((i + 1)) ]; then
+			# Can't replace all at once.
+			not lvconvert $replace $vg/$lv1
+		else
+			lvconvert $replace $vg/$lv1
+		fi
+	done
+	done
+
+	lvremove -ff $vg
+done
+
+# RAID 4/5/6 (can replace up to 'parity' devices)
+for i in 4 5 6; do
+	lvcreate --type raid$i -i 3 -l 3 -n $lv1 $vg
+
+	if [ $i -eq 6 ]; then
+		dev_cnt=5
+		limit=2
+	else
+		dev_cnt=4
+		limit=1
+	fi
+
+	for j in {1..3}; do
+	for o in $(seq 0 $i); do
+		replace=""
+
+		devices=( $(get_image_pvs $vg $lv1) )
+
+		for k in $(seq $j); do
+			index=$((($k + $o) % $dev_cnt))
+			replace="$replace --replace ${devices[$index]}"
+		done
+		aux wait_for_sync $vg $lv1
+
+		if [ $j -gt $limit ]; then
+			not lvconvert $replace $vg/$lv1
+		else
+			lvconvert $replace $vg/$lv1
+		fi
+	done
+	done
+
+	lvremove -ff $vg
+done
+
+# RAID10: Can replace 'copies - 1' devices from each stripe
+# Tests are run on 2-way mirror, 3-way stripe RAID10
+aux target_at_least dm-raid 1 3 1 || skip
+
+lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+
+# Can replace any single device
+for i in $(get_image_pvs $vg $lv1); do
+	lvconvert --replace $i $vg/$lv1
+	aux wait_for_sync $vg $lv1
+done
+
+# Can't replace adjacent devices
+devices=( $(get_image_pvs $vg $lv1) )
+not lvconvert --replace ${devices[0]} --replace ${devices[1]} $vg/$lv1
+not lvconvert --replace ${devices[2]} --replace ${devices[3]} $vg/$lv1
+not lvconvert --replace ${devices[4]} --replace ${devices[5]} $vg/$lv1
+
+# Can replace non-adjacent devices
+for i in 0 1; do
+	lvconvert \
+		--replace ${devices[$i]} \
+		--replace ${devices[$(($i + 2))]} \
+		--replace ${devices[$(($i + 4))]} \
+		 $vg/$lv1
+	aux wait_for_sync $vg $lv1
+done
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index c26f694..81e5a5d 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -16,7 +16,7 @@
 ########################################################
 aux target_at_least dm-raid 1 1 0 || skip
 
-aux prepare_pvs 5 20
+aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
 vgcreate -c n -s 512k $vg $(cat DEVICES)
 
 ###########################################
@@ -49,5 +49,24 @@ for i in raid4 \
 done
 
 #
+# Create RAID10:
+#
+
+aux target_at_least dm-raid 1 3 0 || skip
+
+# Should not allow more than 2-way mirror
+not lvcreate --type raid10 -m 2 -i 2 -l 2 -n $lv1 $vg
+
+# 2-way mirror, 2-stripes
+lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+lvremove -ff $vg
+
+# 2-way mirror, 3-stripes
+lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+lvremove -ff $vg
+
+#
 # FIXME: Add tests that specify particular PVs to use for creation
 #
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2cb6ac0..aac8c22 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -702,6 +702,10 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 
 	/* Set default segtype */
 	if (arg_count(cmd, mirrors_ARG))
+		/*
+		 * FIXME: Add default setting for when -i and -m arguments
+		 *        are both given.  We should default to "raid10".
+		 */
 		segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
 	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
 		segtype_str = "thin";
@@ -735,7 +739,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 
 	lp->mirrors = 1;
 
-	/* Default to 2 mirrored areas if '--type mirror|raid1' */
+	/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
 	if (segtype_is_mirrored(lp->segtype))
 		lp->mirrors = 2;
 
@@ -748,6 +752,18 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			}
 			log_print("Redundant mirrors argument: default is 0");
 		}
+
+		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, "raid10")) {
+			/*
+			 * FIXME: When RAID10 is no longer limited to
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
@@ -787,6 +803,16 @@ static int _lvcreate_params(struct lvcreate_params *lp,
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
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 64474e0..05041af 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -578,6 +578,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 				seg_mirrors = 0;
 			break;
 		}
+
 		if (!arg_count(cmd, mirrors_ARG) && seg_mirrors) {
 			log_print("Extending %" PRIu32 " mirror images.",
 				  seg_mirrors);
@@ -588,18 +589,26 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
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


