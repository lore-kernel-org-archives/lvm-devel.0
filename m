From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 12:49:25 -0400
Subject: master - cleanup: update messages
Message-ID: <201706231649.v5NGnPlG019909@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc03a872c09941f2dbd1c9d3f2d7e89070649d17
Commit:        cc03a872c09941f2dbd1c9d3f2d7e89070649d17
Parent:        a7c7d53543c37e9a3366b88399d4f7c8be2ddf58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 10:59:12 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:44:01 2017 +0200

cleanup: update messages

---
 lib/metadata/raid_manip.c |    8 ++++----
 tools/toollib.c           |   12 ++++++------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 74fafa3..c943976 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -122,13 +122,13 @@ static int _check_region_size_constraints(struct logical_volume *lv,
 					  uint32_t stripe_size)
 {
 	if (region_size < stripe_size) {
-		log_error("Regionsize may not be smaller than stripe size on %s LV %s.",
+		log_error("Region size may not be smaller than stripe size on %s LV %s.",
 			  segtype->name, display_lvname(lv));
 		return 0;
 	}
 
 	if (region_size > lv->size) {
-		log_error("Regionsize too large for %s LV %s.",
+		log_error("Region size is too large for %s LV %s.",
 			   segtype->name, display_lvname(lv));
 		return 0;
 	}
@@ -2442,14 +2442,14 @@ static int _reshape_requested(const struct logical_volume *lv, const struct segm
 	    !seg_is_any_raid0(seg) &&
 	    (region_size || stripe_size) &&
 	    ((region_size ?: seg->region_size) < (stripe_size ?: seg->stripe_size))) {
-		log_error("region size may not be smaller than stripe size on LV %s.",
+		log_error("Region size may not be smaller than stripe size on LV %s.",
 			  display_lvname(lv));
 		return 2;
 	}
 
 	if (seg_is_any_raid10(seg) && seg->area_count > 2 &&
 	    stripes && stripes < seg->area_count - seg->segtype->parity_devs) {
-		log_error("Can't remove stripes from raid10");
+		log_error("Can't remove stripes from raid10.");
 		return 2;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index e5a854f..622dbf3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3762,7 +3762,7 @@ int process_each_lv(struct cmd_context *cmd,
 			ret_max = ret;
 		if (dm_list_empty(&arg_vgnames) && dm_list_empty(&arg_tags)) {
 			ret_max = ECMD_FAILED;
-			goto out;
+			goto_out;
 		}
 	}
 
@@ -4693,7 +4693,7 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 	if (arg_is_set(cmd, pvmetadatacopies_ARG) &&
 	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
 	    pp->pva.metadataignore) {
-		log_error("metadataignore only applies to metadatacopies > 0");
+		log_error("metadataignore only applies to metadatacopies > 0.");
 		return 0;
 	}
 
@@ -4711,7 +4711,7 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 	}
 
 	if (arg_sign_value(cmd, dataalignmentoffset_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Physical volume data alignment offset may not be negative");
+		log_error("Physical volume data alignment offset may not be negative.");
 		return 0;
 	}
 	pp->pva.data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
@@ -4725,7 +4725,7 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 	    (pp->pva.pe_start != PV_PE_START_CALC)) {
 		if ((pp->pva.data_alignment ? pp->pva.pe_start % pp->pva.data_alignment : pp->pva.pe_start) != pp->pva.data_alignment_offset) {
 			log_warn("WARNING: Ignoring data alignment %s"
-				 " incompatible with restored pe_start value %s)",
+				 " incompatible with restored pe_start value %s.",
 				 display_size(cmd, pp->pva.data_alignment + pp->pva.data_alignment_offset),
 				 display_size(cmd, pp->pva.pe_start));
 			pp->pva.data_alignment = 0;
@@ -4878,10 +4878,10 @@ static void _check_pvcreate_prompt(struct cmd_context *cmd,
 				log_error("PV %s is used by VG %s so please use vgreduce first.", pvname, vgname);
 			log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
 		} else if (pp->yes) {
-			log_warn("WARNING: PV %s is used by VG %s", pvname, vgname);
+			log_warn("WARNING: PV %s is used by VG %s.", pvname, vgname);
 			answer_yes = 1;
 		} else if (ask) {
-			log_warn("WARNING: PV %s is used by VG %s", pvname, vgname);
+			log_warn("WARNING: PV %s is used by VG %s.", pvname, vgname);
 			if (yes_no_prompt("Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ", pvname, vgname) == 'n')
 				answer_no = 1;
 			else


