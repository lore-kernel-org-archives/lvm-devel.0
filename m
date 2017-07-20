From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:19:18 -0400
Subject: master - tidy: drop unneeded cast
Message-ID: <201707201019.v6KAJIbG016555@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48ce8c7a49a963a3d1357ad2b964f46902a2c163
Commit:        48ce8c7a49a963a3d1357ad2b964f46902a2c163
Parent:        4a2994b7b1ff4a09f250f6389894a3072d7e3acd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 20 09:57:09 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 11:20:44 2017 +0200

tidy: drop unneeded cast

Avoid casting to the same type.
---
 lib/device/dev-type.c         |    2 +-
 lib/format_text/format-text.c |    6 +++---
 lib/metadata/metadata.c       |    2 +-
 lib/metadata/pv_manip.c       |   10 +++++-----
 lib/metadata/raid_manip.c     |    2 +-
 liblvm/lvm_lv.c               |    3 +--
 liblvm/lvm_vg.c               |    2 +-
 tools/command.c               |    4 ++--
 tools/toollib.c               |    4 ++--
 9 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index aa22e3b..05e5bef 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -76,7 +76,7 @@ struct dev_types *create_dev_types(const char *proc_dir,
 			i++;
 
 		/* If it's not a number it may be name of section */
-		line_maj = atoi(((char *) (line + i)));
+		line_maj = atoi(line + i);
 
 		if (line_maj < 0 || line_maj >= NUMBER_OF_MAJORS) {
 			/*
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 91f8816..7db4637 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2291,9 +2291,9 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		}
 
 		/* Wipe metadata area with zeroes. */
-		if (!dev_set((struct device *) pv->dev, mda_start,
-			(size_t) ((mda_size > wipe_size) ?
-				  wipe_size : mda_size), 0)) {
+		if (!dev_set(pv->dev, mda_start,
+			     (size_t) ((mda_size > wipe_size) ?
+				       wipe_size : mda_size), 0)) {
 				log_error("Failed to wipe new metadata area "
 					  "at the %s of the %s",
 					   mda_index ? "end" : "start",
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ce2e3cc..bbbf7d0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1294,7 +1294,7 @@ static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bi
 	char buf[32];
 	uint32_t i = num_bits - num_set_bits;
 
-	if (!(bs = dm_bitset_create(mem, (unsigned) num_bits))) {
+	if (!(bs = dm_bitset_create(mem, num_bits))) {
 		log_error("Failed to allocate bitset for setting random bits.");
 		return NULL;
 	}
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index de6644e..f37bc4c 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -648,23 +648,23 @@ int pv_resize_single(struct cmd_context *cmd,
 			log_warn("WARNING: %s: Overriding real size %s. You could lose data.",
 				 pv_name, display_size(cmd, (uint64_t) size));
 			if (!yes && yes_no_prompt("%s: Requested size %s exceeds real size %s. Proceed?  [y/n]: ",
-						  pv_name, display_size(cmd, (uint64_t) new_size),
-						  display_size(cmd, (uint64_t) size)) == 'n') {
+						  pv_name, display_size(cmd, new_size),
+						  display_size(cmd, size)) == 'n') {
 				log_error("Physical Volume %s not resized.", pv_name);
 				goto_out;
 			}
 
 		}  else if (new_size < size)
 			if (!yes && yes_no_prompt("%s: Requested size %s is less than real size %s. Proceed?  [y/n]: ",
-						  pv_name, display_size(cmd, (uint64_t) new_size),
-						  display_size(cmd, (uint64_t) size)) == 'n') {
+						  pv_name, display_size(cmd, new_size),
+						  display_size(cmd, size)) == 'n') {
 				log_error("Physical Volume %s not resized.", pv_name);
 				goto_out;
 			}
 
 		if (new_size == size)
 			log_verbose("%s: Size is already %s (%" PRIu64 " sectors).",
-				    pv_name, display_size(cmd, (uint64_t) new_size), new_size);
+				    pv_name, display_size(cmd, new_size), new_size);
 		else
 			log_warn("WARNING: %s: Pretending size is %" PRIu64 " not %" PRIu64 " sectors.",
 				 pv_name, new_size, size);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d96eceb..895bb73 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1834,7 +1834,7 @@ static int _reshape_adjust_to_size(struct logical_volume *lv,
 
 	/* Externally visible LV size w/o reshape space */
 	lv->le_count = seg->len = new_le_count;
-	lv->size = (uint64_t) (lv->le_count - new_image_count * (uint32_t) _reshape_len_per_dev(seg)) * lv->vg->extent_size;
+	lv->size = (uint64_t) (lv->le_count - new_image_count * _reshape_len_per_dev(seg)) * lv->vg->extent_size;
 	/* seg->area_len does not change */
 
 	if (old_image_count < new_image_count) {
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 13d6cbf..580e942 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -65,8 +65,7 @@ const char *lvm_lv_get_name(const lv_t lv)
 {
 	const char *rc;
 	struct saved_env e = store_user_env(lv->vg->cmd);
-	rc = dm_pool_strndup(lv->vg->vgmem, (const char *)lv->name,
-			       NAME_LEN+1);
+	rc = dm_pool_strndup(lv->vg->vgmem, lv->name, NAME_LEN+1);
 	restore_user_env(&e);
 	return rc;
 }
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 8f83230..5593579 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -444,7 +444,7 @@ const char *lvm_vg_get_name(const vg_t vg)
 {
 	const char *rc;
 	struct saved_env e = store_user_env(vg->cmd);
-	rc = dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
+	rc = dm_pool_strndup(vg->vgmem, vg->name, NAME_LEN+1);
 	restore_user_env(&e);
 	return rc;
 }
diff --git a/tools/command.c b/tools/command.c
index a37d64d..b4e5e76 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1337,8 +1337,8 @@ int command_has_alternate_extents(const char *name)
 
 static int long_name_compare(const void *on1, const void *on2)
 {
-	const struct opt_name * const *optname1 = (const void *)on1;
-	const struct opt_name * const *optname2 = (const void *)on2;
+	const struct opt_name * const *optname1 = on1;
+	const struct opt_name * const *optname2 = on2;
 	return strcmp((*optname1)->long_opt + 2, (*optname2)->long_opt + 2);
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 5e3fedd..c2807b8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4871,8 +4871,8 @@ static void _check_pvcreate_prompt(struct cmd_context *cmd,
 		} else if (ask) {
 			if (prompt->new_size != prompt->size) {
 				if (yes_no_prompt("WARNING: %s: device size %s does not match requested size %s. Proceed? [y/n]: ", pvname,
-						  display_size(cmd, (uint64_t)prompt->size),
-						  display_size(cmd, (uint64_t)prompt->new_size)) == 'n') {
+						  display_size(cmd, prompt->size),
+						  display_size(cmd, prompt->new_size)) == 'n') {
 					answer_no = 1;
 				} else {
 					answer_yes = 1;


