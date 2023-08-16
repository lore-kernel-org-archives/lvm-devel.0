From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Wed, 16 Aug 2023 13:15:29 +0000
Subject: [Git][lvmteam/lvm2][main] 6 commits: lvconvert: fix regresion from integrity check
Message-ID: <64dccbf16b8b2_28a4f9c98378@gitlab-sidekiq-low-urgency-cpu-bound-v2-75cff648c9-wv4gc.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
13225f13 by Zdenek Kabelac at 2023-08-16T11:25:54+02:00
lvconvert: fix regresion from integrity check

Testing code sliped into commit and cause regression in testing for
a raid with integrity.

- - - - -
54617805 by Zdenek Kabelac at 2023-08-16T13:31:01+02:00
lvconvert: use vg mempool

Keep allocation for a VG within vg memory pool.

- - - - -
41e4cefc by Christian Hesse at 2023-08-16T15:13:00+02:00
make: make install_libexec a target of install_lvm2

This makes sure libexec scripts are available for lvm2 commands.

- - - - -
085c3821 by Zdenek Kabelac at 2023-08-16T15:13:00+02:00
cleanup: no longer used

Previous commit made this var unused.

- - - - -
728617d2 by Zdenek Kabelac at 2023-08-16T15:13:25+02:00
gcc: cleanup warnings

Correcting signess comparation.
Also use standalone /* fall through */ comment as that&#39;s
the only one supported by gcc to quiet warning.

- - - - -
5a96ca4a by Zdenek Kabelac at 2023-08-16T15:14:29+02:00
tests: update pool uuid handling

Pools now preserve meta LV UUID with swapmetadata operation
to make the usage of lvmlockd easier.

Update test to reflect this change.

- - - - -


8 changed files:

- daemons/cmirrord/local.c
- lib/metadata/metadata.c
- libdm/datastruct/bitset.c
- scripts/Makefile.in
- test/shell/lvconvert-cache.sh
- test/shell/lvconvert-thin.sh
- tools/lvconvert.c
- tools/lvmcmdline.c


Changes:

=====================================
daemons/cmirrord/local.c
=====================================
@@ -266,7 +266,7 @@ static int do_local_work(void *data __attribute__((unused)))
 					  RQ_TYPE(u_rq->request_type));
 			break;
 		}
-		/* ELSE, fall through */
+		/* ELSE */ /* fall through */
 	case DM_ULOG_IS_CLEAN:
 	case DM_ULOG_FLUSH:
 	case DM_ULOG_MARK_REGION:


=====================================
lib/metadata/metadata.c
=====================================
@@ -1133,7 +1133,7 @@ uint32_t extents_from_percent_size(struct volume_group *vg, const struct dm_list
 			}
 			break;
 		}
-		/* fall through to use all PVs in VG like %FREE */
+		/* fall through */ /* to use all PVs in VG like %FREE */
 	case PERCENT_FREE:
 		if (!(extents = vg->free_count)) {
 			log_error("No free extents in Volume group %s.", vg->name);


=====================================
libdm/datastruct/bitset.c
=====================================
@@ -149,7 +149,8 @@ dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem,
 				 size_t min_num_bits)
 {
 	unsigned a, b;
-	int c, old_c, totaldigits, ndigits, nmaskbits;
+	int c, old_c, totaldigits, ndigits;
+	size_t nmaskbits;
 	int at_start, in_range;
 	dm_bitset_t mask = NULL;
 	const char *start = str;


=====================================
scripts/Makefile.in
=====================================
@@ -51,7 +51,7 @@ vpath %.ocf $(srcdir)
 	$(Q) $(INSTALL_DIR) $(ocf_scriptdir)
 	$(Q) $(INSTALL_SCRIPT) $< $(ocf_scriptdir)/$(basename $(<F))
 
-install_lvm2: $(LVM_SCRIPTS:.sh=_install)
+install_lvm2: install_libexec $(LVM_SCRIPTS:.sh=_install)
 install_device-mapper: $(DM_SCRIPTS:.sh=_install)
 
 install_ocf: $(OCF_SCRIPTS:.ocf=_install)
@@ -60,7 +60,7 @@ install_libexec:
 	$(Q) $(INSTALL_DIR) $(libexecdir)
 	$(Q) $(INSTALL_SCRIPT) lvresize_fs_helper.sh $(libexecdir)/lvresize_fs_helper
 
-install: install_lvm2 install_ocf install_device-mapper install_libexec
+install: install_lvm2 install_ocf install_device-mapper
 
 
 # FIXME Customise for other distributions


=====================================
test/shell/lvconvert-cache.sh
=====================================
@@ -60,14 +60,14 @@ check lv_field $vg/$lv2 cache_settings "random_threshold=56,sequential_threshold
 
 # Check swap of cache pool metadata
 lvconvert --yes --type cache-pool --poolmetadata $lv4 $vg/$lv3
-UUID=$(get lv_field $vg/$lv5 uuid)
+UUID=$(get lv_field $vg/${lv3}_cmeta uuid)
 lvconvert --yes --cachepool $vg/$lv3 --poolmetadata $lv5
 check lv_field $vg/${lv3}_cmeta uuid "$UUID"
 
 # Check swap of cache pool metadata with --swapmetadata
 # (should swap back to lv5)
 lvconvert --yes --swapmetadata $vg/$lv3 --poolmetadata $lv5
-check lv_field $vg/$lv5 uuid "$UUID"
+check lv_field $vg/${lv3}_cmeta uuid "$UUID"
 
 #fail lvconvert --cachepool $vg/$lv1 --poolmetadata $vg/$lv2
 #lvconvert --yes --type cache-pool --poolmetadata $vg/$lv2 $vg/$lv1


=====================================
test/shell/lvconvert-thin.sh
=====================================
@@ -82,7 +82,7 @@ lvcreate -L32 -n $lv2 $vg
 lvconvert --yes -c 8M --type thin-pool $vg/$lv1 2>&1 | tee err
 # Check there is a warning for large chunk size and zeroing enabled
 grep "WARNING: Pool zeroing and" err
-UUID=$(get lv_field $vg/$lv2 uuid)
+UUID=$(get lv_field $vg/${lv1}_tmeta uuid)
 # Fail is pool is active
 # TODO  maybe detect inactive pool and deactivate
 fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
@@ -92,7 +92,7 @@ check lv_field $vg/${lv1}_tmeta uuid "$UUID"
 
 # and swap again with new command --swapmetadata
 lvconvert --yes --swapmetadata $vg/$lv1 --poolmetadata $lv2
-check lv_field $vg/$lv2 uuid "$UUID"
+check lv_field $vg/${lv1}_tmeta uuid "$UUID"
 lvremove -f $vg
 
 


=====================================
tools/lvconvert.c
=====================================
@@ -1352,7 +1352,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		else
 			image_count = lp->mirrors + 1;
 
-		images_reduced = (image_count < lv_raid_image_count(lv));
+		images_reduced = (image_count < (int) lv_raid_image_count(lv));
 
 		if (image_count < 1) {
 			log_error("Unable to %s images by specified amount.",
@@ -2834,7 +2834,6 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	struct lv_segment *seg;
 	struct lv_type *lvtype;
 	char meta_name[NAME_LEN];
-	const char *swap_name;
 	const char *swap_lock_args;
 	uint32_t chunk_size;
 	int is_thinpool;
@@ -3115,9 +3114,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 	/* An existing LV needs to have its lock freed once it becomes a data LV. */
 	if (vg_is_shared(vg) && lv->lock_args) {
-		lockd_data_args = dm_pool_strdup(cmd->mem, lv->lock_args);
-		lockd_data_name = dm_pool_strdup(cmd->mem, lv->name);
-		memcpy(&lockd_data_id, &lv->lvid.id[1], sizeof(struct id));
+		lockd_data_args = dm_pool_strdup(lv->vg->vgmem, lv->lock_args);
+		lockd_data_name = dm_pool_strdup(lv->vg->vgmem, lv->name);
+		lockd_data_id = lv->lvid.id[1];
 	}
 
 	/* If LV is inactive here, ensure it's not active elsewhere. */
@@ -3144,9 +3143,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
 		if (vg_is_shared(vg) && metadata_lv->lock_args) {
-			lockd_meta_args = dm_pool_strdup(cmd->mem, metadata_lv->lock_args);
-			lockd_meta_name = dm_pool_strdup(cmd->mem, metadata_lv->name);
-			memcpy(&lockd_meta_id, &metadata_lv->lvid.id[1], sizeof(struct id));
+			lockd_meta_args = dm_pool_strdup(metadata_lv->vg->vgmem, metadata_lv->lock_args);
+			lockd_meta_name = dm_pool_strdup(metadata_lv->vg->vgmem, metadata_lv->name);
+			lockd_meta_id = metadata_lv->lvid.id[1];
 		}
 
 		if (metadata_lv == lv) {
@@ -3550,9 +3549,9 @@ static int _cache_vol_attach(struct cmd_context *cmd,
 	 * lock does not need to be created for it again.)
 	 */
 	if (vg_is_shared(vg) && lv_fast->lock_args) {
-		lockd_fast_args = dm_pool_strdup(cmd->mem, lv_fast->lock_args);
-		lockd_fast_name = dm_pool_strdup(cmd->mem, lv_fast->name);
-		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
+		lockd_fast_args = dm_pool_strdup(lv_fast->vg->vgmem, lv_fast->lock_args);
+		lockd_fast_name = dm_pool_strdup(lv_fast->vg->vgmem, lv_fast->name);
+		lockd_fast_id = lv_fast->lvid.id[1];
 	}
 
 	/*
@@ -6273,9 +6272,9 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	 * lv_wcorig gets no lock.
 	 */
 	if (vg_is_shared(vg) && lv_fast->lock_args) {
-		lockd_fast_args = dm_pool_strdup(cmd->mem, lv_fast->lock_args);
-		lockd_fast_name = dm_pool_strdup(cmd->mem, lv_fast->name);
-		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
+		lockd_fast_args = dm_pool_strdup(lv_fast->vg->vgmem, lv_fast->lock_args);
+		lockd_fast_name = dm_pool_strdup(lv_fast->vg->vgmem, lv_fast->name);
+		lockd_fast_id = lv_fast->lvid.id[1];
 	}
 
 	if (!_writecache_zero(cmd, lv_fast)) {
@@ -6393,8 +6392,8 @@ int lvconvert_to_cache_with_cachevol_cmd(struct cmd_context *cmd, int argc, char
 
 static int _lvconvert_integrity_remove(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	if (!lv_is_integrity(lv)) {
-		log_error("LV does not have integrity.");
+	if (!lv_is_integrity(lv) && !lv_is_raid(lv)) {
+		log_error("LV %s does not have integrity.", display_lvname(lv));
 		return 0;
 	}
 


=====================================
tools/lvmcmdline.c
=====================================
@@ -1456,7 +1456,7 @@ static int _command_optional_opt_matches(struct cmd_context *cmd, int ci, int oo
 	}
 
 	if (val_bit_is_set(commands[ci].optional_opt_args[oo].def.val_bits, constnum_VAL)) {
-		if (commands[ci].optional_opt_args[oo].def.num == arg_int_value(cmd, opt_enum, 0))
+		if (commands[ci].optional_opt_args[oo].def.num == arg_uint64_value(cmd, opt_enum, 0))
 			return 1;
 		return 0;
 	}
@@ -1475,7 +1475,7 @@ static int _command_ignore_opt_matches(struct cmd_context *cmd, int ci, int io)
 	}
 
 	if (val_bit_is_set(commands[ci].ignore_opt_args[io].def.val_bits, constnum_VAL)) {
-		if (commands[ci].ignore_opt_args[io].def.num == arg_int_value(cmd, opt_enum, 0))
+		if (commands[ci].ignore_opt_args[io].def.num == arg_uint64_value(cmd, opt_enum, 0))
 			return 1;
 		return 0;
 	}
@@ -1519,7 +1519,7 @@ check_val:
 	}
 
 	if (val_bit_is_set(commands[ci].required_opt_args[ro].def.val_bits, constnum_VAL)) {
-		if (commands[ci].required_opt_args[ro].def.num == arg_int_value(cmd, opt_enum, 0))
+		if (commands[ci].required_opt_args[ro].def.num == arg_uint64_value(cmd, opt_enum, 0))
 			return 1;
 		return 0;
 	}



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/e548afd1756418933678d2014a8d3f7e5f6b3741...5a96ca4a7fedf873f9b707f35f584d9bde56b357

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/e548afd1756418933678d2014a8d3f7e5f6b3741...5a96ca4a7fedf873f9b707f35f584d9bde56b357
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230816/d725ad95/attachment-0001.htm>
