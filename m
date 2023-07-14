From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Fri, 14 Jul 2023 14:56:51 +0000
Subject: [Git][lvmteam/lvm2][main] 9 commits: lvconvert: no metadata for test mode
Message-ID: <64b16233ead20_28fe4b10692ba@gitlab-sidekiq-low-urgency-cpu-bound-v2-f56cf8895-5fsqx.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
bdcfd2d7 by Zdenek Kabelac at 2023-07-14T16:20:30+02:00
lvconvert: no metadata for test mode

Avoid trying to build real metadata in --test mode.

- - - - -
8eb3a5b5 by Zdenek Kabelac at 2023-07-14T16:51:46+02:00
lvconvert: thin convert locking

Fix locking when converting thick to thin LV, ensure
we take pool lock for shared VG.

- - - - -
75b28ab4 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
lvmlockd: query the simplest check first

Check for visibility of the LV first.

TODO:

Short check list and test only for those that can&#39;t be locked,
but they are visible LVs.

- - - - -
8cbba1d1 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
lvmlockd: enable vdo conversion

As we turn &#39;already&#39; active/locked LV into a data LV of vdopool,
we just keep active lock for such volume (uuid is preserved).

- - - - -
a2b2ae35 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
lvresize: improve usepolices

lvresize --usepolicy requires resized LVs to be active.
(So it&#39;s not only required for shared VG).

The test for active pool needs to use lv_info to query &#39;layer&#39;
otherwise the pool is considered inactive if it was not activated
explicitely - thun &#39;implicit&#39; activation with VDO or ThinLV was
not managed by --usepolicy option.

- - - - -
b89fc056 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
cleanup: indent

- - - - -
a9977146 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
tests: skip with lvmpolld

Not needed with lvmpolld pass.

- - - - -
482501c2 by Zdenek Kabelac at 2023-07-14T16:52:51+02:00
tests: more checks with active thin lv

Check --usepolicy works primarily when thin-pool -tpool is there.
Also let the test run with lvmlockd.

- - - - -
1c60c678 by Zdenek Kabelac at 2023-07-14T16:53:34+02:00
tests: check --test

Check lvconvert --thin is not adding more LVs.
Enable testing with lvmlockd.

TODO: lvmlockd is missing support for --test.

- - - - -


9 changed files:

- lib/locking/lvmlockd.c
- lib/metadata/thin_manip.c
- test/shell/devicesfile-vpd-ids.sh
- test/shell/lvconvert-thin-from-thick.sh
- test/shell/lvconvert-twostep.sh
- test/shell/lvextend-thin-full.sh
- test/shell/vgimportdevices.sh
- tools/lvconvert.c
- tools/lvresize.c


Changes:

=====================================
lib/locking/lvmlockd.c
=====================================
@@ -3315,6 +3315,9 @@ out:
 
 int lockd_lv_uses_lock(struct logical_volume *lv)
 {
+	if (!lv_is_visible(lv))
+		return 0;
+
 	if (lv_is_thin_volume(lv))
 		return 0;
 
@@ -3368,9 +3371,6 @@ int lockd_lv_uses_lock(struct logical_volume *lv)
 	if (lv_is_raid_metadata(lv))
 		return 0;
 
-	if (!lv_is_visible(lv))
-		return 0;
-
 	return 1;
 }
 


=====================================
lib/metadata/thin_manip.c
=====================================
@@ -497,6 +497,11 @@ int thin_pool_prepare_metadata(struct logical_volume *metadata_lv,
 		return 0;
 	}
 
+	if (test_mode()) {
+		log_verbose("Test mode: Skipping creation of provisioned thin pool metadata.");
+		return 1;
+	}
+
 	/* coverity[secure_temp] until better solution */
 	if (!(f = tmpfile())) {
 		log_error("Cannot create temporary file to prepare metadata.");


=====================================
test/shell/devicesfile-vpd-ids.sh
=====================================
@@ -12,6 +12,8 @@
 
 test_description='device id wwid from vpd_pg83'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 test "$DM_DEV_DIR" = "/dev" || skip "Only works with /dev access -> make check LVM_TEST_DEVDIR=/dev"


=====================================
test/shell/lvconvert-thin-from-thick.sh
=====================================
@@ -12,7 +12,6 @@
 
 # Test conversion to thin volume from thick LVs
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -50,6 +49,16 @@ lvcreate --type zero -L2T -n $lv1 $vg
 lvconvert --yes --type thin  $vg/$lv1
 lvremove -f $vg
 
+# zero -> thin --test
+if [ ! -e LOCAL_LVMLOCKD ] ; then
+# FIXME: missing support with lvmlockd
+lvcreate --type zero -L2T -n $lv1 $vg
+lvconvert --yes --type thin --test $vg/$lv1
+check lv_field $vg/$lv1 segtype zero
+check vg_field $vg lv_count 1
+lvremove -f $vg
+fi
+
 # linear -> thin
 lvcreate -L10 -n $lv1 $vg
 _convert_to_thin


=====================================
test/shell/lvconvert-twostep.sh
=====================================
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 


=====================================
test/shell/lvextend-thin-full.sh
=====================================
@@ -14,7 +14,6 @@
 # play with thin-pool resize in corner cases
 #
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -34,9 +33,10 @@ aux lvmconf 'activation/thin_pool_autoextend_percent = 30' \
 	    'activation/thin_pool_autoextend_threshold = 70'
 
 aux prepare_thin_metadata 400 0 | tee data
-lvcreate -L200 -T $vg/pool
+lvcreate -L200 -V10 -n $lv2 -T $vg/pool
 lvchange -an $vg
 
+# Prepare full metadata volume
 lvcreate -L2M -n $lv1 $vg
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
@@ -44,7 +44,7 @@ lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 # active thin pool is needed to use policy
 not lvextend --use-policies $vg/pool 2>&1 | tee err
 
-lvchange -ay $vg
+lvchange -ay $vg/$lv2
 
 # Cannot resize if set to 0%
 not lvextend --use-policies --config 'activation{thin_pool_autoextend_percent = 0}' $vg/pool 2>&1 | tee err


=====================================
test/shell/vgimportdevices.sh
=====================================
@@ -12,6 +12,8 @@
 
 test_description='vgimportdevices'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_devs 5


=====================================
tools/lvconvert.c
=====================================
@@ -3024,7 +3024,7 @@ static struct logical_volume *_lvconvert_insert_thin_layer(struct logical_volume
 static int _lvconvert_attach_metadata_to_pool(struct lv_segment *pool_seg,
 					      struct logical_volume *metadata_lv)
 {
-        struct cmd_context *cmd = metadata_lv->vg->cmd;
+	struct cmd_context *cmd = metadata_lv->vg->cmd;
 	char name[NAME_LEN];                   /* generated sub lv name */
 
 	if (!deactivate_lv(cmd, metadata_lv)) {
@@ -3398,6 +3398,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 * data and meta LVs (they are unlocked and deleted below.)
 	 */
 	if (vg_is_shared(vg)) {
+		lv->lock_args = NULL;
 		pool_lv->lock_args = NULL;
 		data_lv->lock_args = NULL;
 		metadata_lv->lock_args = NULL;
@@ -3455,6 +3456,10 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		goto_bad;
 
 	if (to_thin) {
+		if (!lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
+			log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
+			goto out;
+		}
 		if (!lv_update_and_reload(lv))
 			goto_bad;
 	} else {
@@ -5494,18 +5499,16 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		}
 	}
 
-	if (vg_is_shared(vg)) {
-		/* FIXME: need to swap locks betwen LVs? */
-		log_error("Unable to convert VDO pool in VG with lock_type %s", vg->lock_type);
-		goto out;
-	}
-
 	if (!fill_vdo_target_params(cmd, &vdo_params, &vdo_pool_header_size, vg->profile))
 		goto_out;
 
 	if (!get_vdo_settings(cmd, &vdo_params, NULL))
 		goto_out;
 
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		goto_out;
+
 	if (!activate_lv(cmd, lv)) {
 		log_error("Cannot activate %s.", display_lvname(lv));
 		goto out;


=====================================
tools/lvresize.c
=====================================
@@ -259,29 +259,22 @@ out:
 static int _lv_extend_policy(struct cmd_context *cmd, struct logical_volume *lv,
 			     struct lvresize_params *lp, int *skipped)
 {
-	struct lvresize_params lp_meta;
 	uint32_t percent_main = 0;
 	uint32_t percent_meta = 0;
 	int is_active;
 
-	memset(&lp_meta, 0, sizeof(lp_meta));
-
-	if (!lv_is_cow(lv) && !lv_is_thin_pool(lv) && !lv_is_vdo_pool(lv)) {
+	if (lv_is_cow(lv))
+		is_active = lv_is_active(lv);
+	else if (lv_is_thin_pool(lv) || lv_is_vdo_pool(lv))
+		/* check for -layer active LV */
+		is_active = lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0);
+	else {
 		log_error("lvextend policy is supported only for snapshot, thin pool and vdo pool volumes.");
-		*skipped = 1;
 		return 0;
 	}
 
-	is_active = lv_is_active(lv);
-
-	if (vg_is_shared(lv->vg) && !is_active) {
-		log_debug("lvextend policy requires LV to be active in a shared VG.");
-		*skipped = 1;
-		return 1;
-	}
-
-	if (lv_is_thin_pool(lv) && !is_active) {
-		log_error("lvextend using policy requires the thin pool to be active.");
+	if (!is_active) {
+		log_error("lvextend using policy requires the volume to be active.");
 		return 0;
 	}
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/93484c2a62afb59f1503d04c953d76255b9e05b3...1c60c6785c222b3fed4747ec11ef3aacebc4a680

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/93484c2a62afb59f1503d04c953d76255b9e05b3...1c60c6785c222b3fed4747ec11ef3aacebc4a680
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230714/10f6062e/attachment-0001.htm>
