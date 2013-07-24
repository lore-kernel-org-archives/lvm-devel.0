From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Jul 2013 15:18:17 +0000 (UTC)
Subject: master - thin: lvconvert cannot convert pool to mirror
Message-ID: <20130724151817.700B4612BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da5284a500338b458ade34c1a88d461acde52b71
Commit:        da5284a500338b458ade34c1a88d461acde52b71
Parent:        7dc21c1597fe57cf7401e074feb8c507cf66aabc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 24 15:25:22 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 24 17:17:19 2013 +0200

thin: lvconvert cannot convert pool to mirror

Suggest to use _tdata and _tmeta devices for that.
This fixes regression from too relaxed change in
f1d5f6ae81f4723e6aeb2f04bd68cba59cd65403

Without this patch there are some empty LVs created before
mirror code recognizes it cannot continue.

(in release fix)
---
 test/shell/lvconvert-thin.sh |    3 +++
 tools/lvconvert.c            |   27 +++++++++++++++++++++++++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index a84c1d1..3cbfd2c 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -95,4 +95,7 @@ grep "WARNING: Chunk size is too small" err
 
 #lvs -a -o+chunk_size,stripe_size,seg_pe_ranges
 
+# Convertions of pool to mirror is unsupported
+not lvconvert -m1 $vg/$lv1
+
 vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 62334d8..bd07497 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1553,6 +1553,27 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _lvconvert_validate_thin(struct logical_volume *lv,
+				    struct lvconvert_params *lp)
+{
+	if (!lv_is_thin_pool(lv) && !lv_is_thin_volume(lv))
+		return 1;
+
+	log_error("Converting thin%s segment type for \"%s/%s\" to %s is not supported.",
+		  lv_is_thin_pool(lv) ? " pool" : "",
+		  lv->vg->name, lv->name, lp->segtype->name);
+
+	if (lv_is_thin_volume(lv))
+		return 0;
+
+	/* Give advice for thin pool conversion */
+	log_error("For pool data volume conversion use \"%s/%s\".",
+		  lv->vg->name, seg_lv(first_seg(lv), 0)->name);
+	log_error("For pool metadata volume conversion use \"%s/%s\".",
+		  lv->vg->name, first_seg(lv)->metadata_lv->name);
+	return 0;
+}
+
 /*
  * _lvconvert_mirrors
  *
@@ -1575,6 +1596,9 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!_lvconvert_validate_thin(lv, lp))
+		return_0;
+
 	/* Adjust mimage and/or log count */
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,
@@ -1676,6 +1700,9 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 		return 0;
 	}
 
+	if (!_lvconvert_validate_thin(lv, lp))
+		return_0;
+
 	if (!is_valid_raid_conversion(seg->segtype, lp->segtype)) {
 		log_error("Unable to convert %s/%s from %s to %s",
 			  lv->vg->name, lv->name,


