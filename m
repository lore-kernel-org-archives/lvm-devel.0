From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Thu, 17 Aug 2023 20:57:19 +0000
Subject: [Git][lvmteam/lvm2][main] 6 commits: pool: use predefined name for metadata LV
Message-ID: <64de89afb87b6_28a7f1c9049a@gitlab-sidekiq-low-urgency-cpu-bound-v2-79bbd7577-fpzr4.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
8698f9dc by Zdenek Kabelac at 2023-08-17T20:10:21+02:00
pool: use predefined name for metadata LV

While create new LV for pool volume, use name from &#39;pool_metadata%d&#39; naming
sequence. This LV is later on renamed to  pool_t/cmeta, but if there
is any error in the middle, we may evenutally leave some &#39;volume&#39;,
With this name it can be slightly more obvious how it got there,
but also when we handle _pmspare name - we get slightly more predictible
name used there for it.

However for a standard usage this commit shall no visible impact as the
name is used temporarily just for cleaning LV.

- - - - -
ad73f571 by Zdenek Kabelac at 2023-08-17T20:14:47+02:00
lvconvert: move _pmspare handling before conversion

- - - - -
dde5b810 by Zdenek Kabelac at 2023-08-17T22:52:08+02:00
lvconvert: run error path code only for shared VG

Error path for locking only for share VG.

- - - - -
ba36ba88 by Zdenek Kabelac at 2023-08-17T22:52:08+02:00
cleanup: move allocation code

Allocate new memory after validation passed.

- - - - -
61499e87 by Zdenek Kabelac at 2023-08-17T22:52:08+02:00
debug: common error handling

- - - - -
5803d9b6 by Zdenek Kabelac at 2023-08-17T22:52:08+02:00
tests: skip some tests with valgrind

Valgrind tends to be too slow for any kind of slowing down,
thus skip some tests that are time sensitive.

- - - - -


5 changed files:

- lib/metadata/pool_manip.c
- test/shell/lvchange-raid1-writemostly.sh
- test/shell/lvconvert-mirror.sh
- test/shell/lvconvert-raid.sh
- tools/lvconvert.c


Changes:

=====================================
lib/metadata/pool_manip.c
=====================================
@@ -628,6 +628,7 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 		.temporary = 1,
 		.zero = 1,
 		.is_metadata = 1,
+		.lv_name = "pool_metadata%d",
 	};
 
 	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))


=====================================
test/shell/lvchange-raid1-writemostly.sh
=====================================
@@ -32,10 +32,12 @@ done
 
 # Create 4-way raid1 LV
 lvcreate -aey --ty raid1 -m 3 -Zn -L16M -n $lv1 $vg
+if test "${LVM_VALGRIND:-0}" -eq 0 ; then
 not lvchange -y --writemostly "$dev1" "$vg/$lv1"
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 4
 check lv_attr_bit health $vg/${lv1}_rimage_0 "-"
+fi
 aux enable_dev "${DEVICES[@]}"
 aux wait_for_sync $vg $lv1
 lvchange -y --writemostly "$dev1" "$vg/$lv1"


=====================================
test/shell/lvconvert-mirror.sh
=====================================
@@ -321,6 +321,7 @@ aux zero_dev "$dev4" "$(get first_extent_sector "$dev4"):"
 
 SHOULD=
 aux throttle_dm_mirror || SHOULD=should
+test "${LVM_VALGRIND:-0}" -eq 0 || SHOULD=should
 
 # Use large enough mirror that takes time to sychronize with small regionsize
 lvcreate -aey -L30 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"


=====================================
test/shell/lvconvert-raid.sh
=====================================
@@ -274,7 +274,7 @@ lvconvert --yes -m +1 $vg/$lv1 "$dev3"
 # should allow 1st primary to be removed
 lvconvert --yes -m -1 $vg/$lv1 "$dev1"
 # should NOT allow last primary to be removed
-not lvconvert --yes -m -1 $vg/$lv1 "$dev2"
+test "${LVM_VALGRIND:-0}" -eq 0 && not lvconvert --yes -m -1 $vg/$lv1 "$dev2"
 # should allow non-primary to be removed
 lvconvert --yes -m 0 $vg/$lv1 "$dev3"
 aux enable_dev "$dev3"


=====================================
tools/lvconvert.c
=====================================
@@ -3092,8 +3092,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	thin_discards_t discards;
 	thin_zero_t zero_new_blocks;
 	int error_when_full;
-	int end_error = 0;
 	int is_active;
+	int ret = 1;
 
 	/* for handling lvmlockd cases */
 	char *lockd_data_args = NULL;
@@ -3122,6 +3122,10 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return 0;
+
 	is_active = lv_is_active(lv);
 
 	activate_pool = to_thinpool && is_active;
@@ -3129,17 +3133,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	/* Wipe metadata_lv by default, but allow skipping this for cache pools. */
 	zero_metadata = (to_cachepool) ? arg_int_value(cmd, zero_ARG, 1) : 1;
 
-	if (vg_is_shared(vg) && lv->lock_args) {
-		lockd_data_args = dm_pool_strdup(vg->vgmem, lv->lock_args);
-		lockd_data_name = dm_pool_strdup(vg->vgmem, lv->name);
-		lockd_data_flags = is_active ? LDLV_PERSISTENT : 0;
-		lockd_data_id = lv->lvid.id[1];
-	}
-
-	/* If LV is inactive here, ensure it's not active elsewhere. */
-	if (!lockd_lv(cmd, lv, "ex", 0))
-		return 0;
-
 	/*
 	 * If an existing LV is to be used as the metadata LV,
 	 * verify that it's in a usable state.  These checks are
@@ -3158,14 +3151,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			return 0;
 		}
 
-		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
-		if (vg_is_shared(vg) && metadata_lv->lock_args) {
-			lockd_meta_args = dm_pool_strdup(vg->vgmem, metadata_lv->lock_args);
-			lockd_meta_name = dm_pool_strdup(vg->vgmem, metadata_lv->name);
-			lockd_meta_flags = lv_is_active(metadata_lv) ? LDLV_PERSISTENT : 0;
-			lockd_meta_id = metadata_lv->lvid.id[1];
-		}
-
 		if (metadata_lv == lv) {
 			log_error("Can't use same LV for pool data and metadata LV %s.",
 				  display_lvname(metadata_lv));
@@ -3212,6 +3197,21 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		/* If LV is inactive here, ensure it's not active elsewhere. */
 		if (!lockd_lv(cmd, metadata_lv, "ex", 0))
 			return 0;
+
+		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
+		if (vg_is_shared(vg) && metadata_lv->lock_args) {
+			lockd_meta_args = dm_pool_strdup(vg->vgmem, metadata_lv->lock_args);
+			lockd_meta_name = dm_pool_strdup(vg->vgmem, metadata_lv->name);
+			lockd_meta_flags = lv_is_active(metadata_lv) ? LDLV_PERSISTENT : 0;
+			lockd_meta_id = metadata_lv->lvid.id[1];
+		}
+	}
+
+	if (vg_is_shared(vg) && lv->lock_args) {
+		lockd_data_args = dm_pool_strdup(vg->vgmem, lv->lock_args);
+		lockd_data_name = dm_pool_strdup(vg->vgmem, lv->name);
+		lockd_data_flags = is_active ? LDLV_PERSISTENT : 0;
+		lockd_data_id = lv->lvid.id[1];
 	}
 
 	if (!get_pool_params(cmd, pool_segtype,
@@ -3356,6 +3356,23 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 	}
 
+	/*
+	 * Before starting a real conversion, prepare  _pmspare volume.
+	 * If there is already one presend in a VG, make sure the size is right
+	 */
+	if (!handle_pool_metadata_spare(vg, metadata_lv->le_count, use_pvh, pool_metadata_spare)) {
+		log_error("Failed to set up spare metadata LV for pool.");
+		goto bad;
+	}
+	/*
+	 * After _pmspare handling is finished there are unwritten VG metadata
+	 * that will get written with the next mda update.
+	 * If there is any failure and such new metadata would not be written,
+	 * a user is then left with 'regular' volume he can normally  'lvremove'.
+	 * If there was _pmspare already existing, the size of such LV is already changed
+	 * and is committed to disk. A user may only remove such volume and create a new one.
+	 */
+
 	if (to_thin) {
 		/*
 		 * pool_lv is not yet a pool, when returned, pool_lv contains
@@ -3453,7 +3470,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		if (to_thin) {
 			if (!lockd_init_lv_args(cmd, vg, pool_lv, vg->lock_type, &pool_lv->lock_args)) {
 				log_error("Cannot allocate lock for new pool LV.");
-				goto_bad;
+				goto bad;
 			}
 		} else if (to_thinpool) {
 			pool_lv->lock_args = lockd_data_args;
@@ -3466,7 +3483,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		if ((to_thin || to_thinpool) && is_active) {
 			if (!lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
 				log_error("Failed to lock new pool LV %s.", display_lvname(pool_lv));
-				goto_bad;
+				goto bad;
 			}
 			lock_active_pool_done = 1;
 		}
@@ -3492,21 +3509,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 				 (to_cachepool) ? "cache" : "thin",
 				 (to_thin) ? "volume" : "pool");
 
-	/*
-	 * FIXME handle_pool_metadata_spare() calls vg_write() vg_commit()
-	 * after creating a new lvolN, but then lvolN is renamed and hidden as
-	 * [lvolN_pmspare] without any further vg_write(). So, there's an extra
-	 * vg_write and vg_commit required here to cover the renaming/hiding.
-	 */
-	if (!handle_pool_metadata_spare(vg, metadata_lv->le_count, use_pvh, pool_metadata_spare) ||
-	    !vg_write(vg) || !vg_commit(vg)) {
-		log_error("Failed to set up spare metadata LV for thin pool.");
-		end_error = 1;
-	}
-
 	if (activate_pool && !activate_lv(cmd, pool_lv)) {
 		log_error("Failed to activate pool logical volume %s.", display_lvname(pool_lv));
-		end_error = 1;
+		ret = 0;
 	}
 
 	/*
@@ -3515,33 +3520,31 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	if (lockd_data_name) {
 		if (!lockd_lv_name(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args, "un", lockd_data_flags)) {
 			log_error("Failed to unlock pool data LV %s/%s", vg->name, lockd_data_name);
-			end_error = 1;
+			ret = 0;
 		}
 		if (!lockd_free_lv(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args)) {
 			log_error("Failed to free lock for pool data LV %s/%s", vg->name, lockd_data_name);
-			end_error = 1;
+			ret = 0;
 		}
 	}
 	if (lockd_meta_name) {
 		if (!lockd_lv_name(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args, "un", lockd_meta_flags)) {
 			log_error("Failed to unlock pool metadata LV %s/%s", vg->name, lockd_meta_name);
-			end_error = 1;
+			ret = 0;
 		}
 		if (!lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args)) {
 			log_error("Failed to free lock for pool metadata LV %s/%s", vg->name, lockd_meta_name);
-			end_error = 1;
+			ret = 0;
 		}
 	}
 
 	if (policy_settings)
 		dm_config_destroy(policy_settings);
 
-	if (end_error) {
+	if (!ret)
 		log_error("Manual intervention may be required to handle reported errors.");
-		return 0;
-	}
 
-	return 1;
+	return ret;
 
 	/*
 	 * Error exit path for failures that occur before the main conversion
@@ -3549,10 +3552,12 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 * committed should not exit here.  There is some cleanup missing here.
 	 */
 bad:
-	if (lock_active_pool_done)
-		lockd_lv(cmd, pool_lv, "un", LDLV_PERSISTENT);
-	if (pool_lv && pool_lv->lock_args && pool_lv->new_lock_args)
-		lockd_free_lv(cmd, vg, pool_lv->name, &pool_lv->lvid.id[1], pool_lv->lock_args);
+	if (vg_is_shared(vg)) {
+		if (lock_active_pool_done)
+			lockd_lv(cmd, pool_lv, "un", LDLV_PERSISTENT);
+		if (pool_lv && pool_lv->lock_args && pool_lv->new_lock_args)
+			lockd_free_lv(cmd, vg, pool_lv->name, &pool_lv->lvid.id[1], pool_lv->lock_args);
+	}
 
 	if (policy_settings)
 		dm_config_destroy(policy_settings);



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/6ca97e6e62852bd491fd19ff98ee41318f902d36...5803d9b689c7da22d618b0f4acb0e2022ed81f7b

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/6ca97e6e62852bd491fd19ff98ee41318f902d36...5803d9b689c7da22d618b0f4acb0e2022ed81f7b
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230817/d61e272a/attachment-0001.htm>
