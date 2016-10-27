From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 27 Oct 2016 09:42:27 +0000 (UTC)
Subject: master - lvchange/vgchange/lvconvert: prevent raid4 creation/activation/conversion on non-supporting raid targets
Message-ID: <20161027094227.DD2426039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff05ed7afd16048b64ee3bd94476b1d19e5022db
Commit:        ff05ed7afd16048b64ee3bd94476b1d19e5022db
Parent:        e84f527cd37fa713774e30c63509bfeef8271618
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 27 11:38:16 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 27 11:42:07 2016 +0200

lvchange/vgchange/lvconvert: prevent raid4 creation/activation/conversion on non-supporting raid targets

Check for dm-raid target version with non-standard raid4 mapping expecting the dedicated
parity device in the last rather than the first slot and prohibit to create, activate or
convert to such LVs from striped/raid0* or vice-versa in order to avoid data corruption.

Add related tests to lvconvert-raid-takeover.sh

Resolves: rhbz1388962
---
 WHATS_NEW                             |    1 +
 lib/activate/activate.c               |   25 +++++++++++++++++++++++++
 lib/activate/activate.h               |    3 ++-
 lib/metadata/lv.c                     |   16 +++++++++++++++-
 lib/metadata/segtype.h                |    3 ++-
 lib/raid/raid.c                       |   10 ++++++++--
 test/shell/lvconvert-raid-takeover.sh |   13 +++++++++++++
 tools/lvconvert.c                     |   25 +++++++++++++++++++++++++
 tools/lvcreate.c                      |    6 ++++++
 9 files changed, 97 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3a8e006..1d0d6dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.167 - 
 ======================================
+  Prevent raid4 creation/conversion on non-supporting kernels
   Add direct striped -> raid4 conversion
   Fix raid4 parity image pair position on conversions from striped/raid0*
   Fix a few unconverted return code values for some lvconvert error path.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 5550955..571f2b2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -370,6 +370,11 @@ void activation_exit(void)
 {
 }
 
+int raid4_is_supported(struct cmd_context *cmd, const struct segment_type *segtype)
+{
+	return 1;
+}
+
 int lv_is_active(const struct logical_volume *lv)
 {
 	return 0;
@@ -1489,6 +1494,26 @@ out:
 	return r || l;
 }
 
+/*
+ * Check if "raid4" @segtype is supported by kernel.
+ *
+ * if segment type is not raid4, return 1.
+ */
+int raid4_is_supported(struct cmd_context *cmd, const struct segment_type *segtype)
+{
+	unsigned attrs;
+
+	if (segtype_is_raid4(segtype) &&
+	    (!segtype->ops->target_present ||
+             !segtype->ops->target_present(cmd, NULL, &attrs) ||
+             !(attrs & RAID_FEATURE_RAID4))) {
+		log_error("RAID module does not support RAID4.");
+		return 0;
+	}
+
+	return 1;
+}
+
 int lv_is_active(const struct logical_volume *lv)
 {
 	return _lv_is_active(lv, NULL, NULL, NULL);
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 1e8d7a8..3922d78 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -99,6 +99,7 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 		   int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,
 		   uint32_t *min, uint32_t *patchlevel);
+int raid4_is_supported(struct cmd_context *cmd, const struct segment_type *segtype);
 int lvm_dm_prefix_check(int major, int minor, const char *prefix);
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 			 struct dm_list *modules);
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 70036f9..14370bb 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1418,6 +1418,7 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		     enum activation_change activate, int needs_exclusive)
 {
 	const char *ay_with_mode = NULL;
+	struct lv_segment *seg = first_seg(lv);
 
 	if (activate == CHANGE_ASY)
 		ay_with_mode = "sh";
@@ -1454,6 +1455,9 @@ deactivate:
 		break;
 	case CHANGE_ALY:
 	case CHANGE_AAY:
+		if (!raid4_is_supported(cmd, seg->segtype))
+			goto no_raid4;
+
 		if (needs_exclusive || _lv_is_exclusive(lv)) {
 			log_verbose("Activating logical volume %s exclusively locally.",
 				    display_lvname(lv));
@@ -1468,6 +1472,9 @@ deactivate:
 		break;
 	case CHANGE_AEY:
 exclusive:
+		if (!raid4_is_supported(cmd, seg->segtype))
+			goto no_raid4;
+
 		log_verbose("Activating logical volume %s exclusively.",
 			    display_lvname(lv));
 		if (!activate_lv_excl(cmd, lv))
@@ -1476,6 +1483,9 @@ exclusive:
 	case CHANGE_ASY:
 	case CHANGE_AY:
 	default:
+		if (!raid4_is_supported(cmd, seg->segtype))
+			goto no_raid4;
+
 		if (needs_exclusive || _lv_is_exclusive(lv))
 			goto exclusive;
 		log_verbose("Activating logical volume %s.", display_lvname(lv));
@@ -1488,6 +1498,10 @@ exclusive:
 		log_error("Failed to unlock logical volume %s.", display_lvname(lv));
 
 	return 1;
+
+no_raid4:
+	log_error("Failed to activate %s LV %s", lvseg_name(seg), display_lvname(lv));
+	return 0;
 }
 
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 9ca740d..292b8b6 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -268,6 +268,7 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 #define RAID_FEATURE_RAID10			(1U << 0) /* version 1.3 */
 #define RAID_FEATURE_RAID0			(1U << 1) /* version 1.7 */
 #define RAID_FEATURE_RESHAPING			(1U << 2) /* version 1.8 */
+#define RAID_FEATURE_RAID4			(1U << 3) /* ! version 1.8 or 1.9.0 */
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 3bc3c75..92a96a3 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -366,7 +366,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 
 	static int _raid_checked = 0;
 	static int _raid_present = 0;
-	static int _raid_attrs = 0;
+	static unsigned _raid_attrs = 0;
 	uint32_t maj, min, patchlevel;
 	unsigned i;
 
@@ -389,6 +389,12 @@ static int _raid_target_present(struct cmd_context *cmd,
 			else
 				log_very_verbose("Target raid does not support %s.",
 						 _features[i].feature);
+
+		if (!(maj == 1 && (min == 8 || (min == 9 && patchlevel == 0))))
+			_raid_attrs |= RAID_FEATURE_RAID4;
+		else
+			log_very_verbose("Target raid does not support %s.",
+					 SEG_TYPE_NAME_RAID4);
 	}
 
 	if (attributes)
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 0140e22..332786d 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -16,6 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_raid 1 9 0 || skip
 
+[ `aux have_raid 1.9.1` ] && correct_raid4_layout=1
+
 aux prepare_vg 9 288
 
 # Delay 1st leg so that rebuilding status characters
@@ -99,6 +101,9 @@ check lv_field $vg/$lv3 stripes 3
 echo y | mkfs -t ext4 /dev/mapper/$vg-$lv3
 fsck -fn  /dev/mapper/$vg-$lv3
 
+if [ $correct_raid4_layout -eq 1 ]
+then
+
 # Create 3-way raid4
 lvcreate -y -aey --type raid4 -i 3 -L 64M -n $lv4 $vg
 check lv_field $vg/$lv4 segtype "raid4"
@@ -164,4 +169,12 @@ check lv_field $vg/$lv1 segtype "striped"
 check lv_field $vg/$lv1 stripes 3
 fsck -fn  /dev/mapper/$vg-$lv1
 
+else
+
+not lvcreate -y -aey --type raid4 -i 3 -L 64M -n $lv4 $vg
+not lvconvert -y --ty raid4 $vg/$lv1
+not lvconvert -y --ty raid4 $vg/$lv2
+
+fi
+
 vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 772c268..90642aa 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1828,6 +1828,25 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd,
 	}
 }
 
+/* Check for dm-raid target supporting raid4 conversion properly. */
+static int _raid4_conversion_supported(struct logical_volume *lv, struct lvconvert_params *lp)
+{
+	int ret = 1;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg_is_raid4(seg))
+		ret = raid4_is_supported(lv->vg->cmd, seg->segtype);
+	else if (segtype_is_raid4(lp->segtype))
+		ret = raid4_is_supported(lv->vg->cmd, lp->segtype);
+
+	if (ret)
+		return 1;
+
+	log_error("Cannot convert %s LV %s to %s.",
+		  lvseg_name(seg), display_lvname(lv), lp->segtype->name);
+	return 0;
+}
+
 static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
 	int replace = 0, image_count = 0;
@@ -1951,6 +1970,9 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
+		if (!_raid4_conversion_supported(lv, lp))
+			return 0;
+
 		if (!arg_is_set(cmd, stripes_long_ARG))
 			lp->stripes = 0;
 
@@ -2008,6 +2030,9 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 try_new_takeover_or_reshape:
 
+	if (!_raid4_conversion_supported(lv, lp))
+		return 0;
+
 	/* FIXME This needs changing globally. */
 	if (!arg_is_set(cmd, stripes_long_ARG))
 		lp->stripes = 0;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 387c8d4..dbc0708 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1054,6 +1054,12 @@ static int _lvcreate_params(struct cmd_context *cmd,
 			return 0;
 		}
 
+		if (segtype_is_raid4(lp->segtype) &&
+		    !(lp->target_attr & RAID_FEATURE_RAID4)) {
+			log_error("RAID module does not support RAID4.");
+			return 0;
+		}
+
 		if (segtype_is_raid10(lp->segtype) && !(lp->target_attr & RAID_FEATURE_RAID10)) {
 			log_error("RAID module does not support RAID10.");
 			return 0;


