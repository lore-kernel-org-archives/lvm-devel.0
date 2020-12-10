From: David Teigland <teigland@sourceware.org>
Date: Thu, 10 Dec 2020 21:42:16 +0000 (GMT)
Subject: main - writecache: fix uncache for two step detach
Message-ID: <20201210214216.3AA44385701F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5dbe2fdd9dd783c2911a5375d6fdec86118af280
Commit:        5dbe2fdd9dd783c2911a5375d6fdec86118af280
Parent:        9fe7aba251ff24c14277dfdf9be2d861a7699230
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 10 15:37:23 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 10 15:42:01 2020 -0600

writecache: fix uncache for two step detach

Fix the two-step writecache detach in commit c32d7fed4f78b.
In the case of uncache, the cachevol is removed after
detaching the writecache.  When the detach is finished
in the second step, the remove must wait until then.
---
 test/shell/writecache-large.sh | 29 ++++++++++++++++++++++++++
 test/shell/writecache-split.sh | 46 ++++++++++++++++++++++++++++++++++++++++++
 tools/lvconvert.c              | 33 ++++++++++++++++++++++++++++--
 3 files changed, 106 insertions(+), 2 deletions(-)

diff --git a/test/shell/writecache-large.sh b/test/shell/writecache-large.sh
index fc8f379cf..9a5a9f1dd 100644
--- a/test/shell/writecache-large.sh
+++ b/test/shell/writecache-large.sh
@@ -149,5 +149,34 @@ lvchange -an $vg/$lv2
 lvremove $vg/$lv1
 lvremove $vg/$lv2
 
+# Repeat similar using uncache
+
+lvcreate -n $lv1 -L 560M -an $vg "$dev1"
+lvcreate -n $lv2 -L 500M -an $vg "$dev2"
+
+lvchange -ay $vg/$lv1
+lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
+
+_add_new_data_to_mnt
+_add_more_data_to_mnt
+dd if=/dev/zero of=$mnt/big1 bs=1M count=100 oflag=sync
+
+umount $mnt
+lvchange -an $vg/$lv1
+
+lvconvert --uncache $vg/$lv1
+
+check lv_field $vg/$lv1 segtype linear
+not lvs $vg/$lv2
+
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+_verify_data_on_mnt
+_verify_more_data_on_mnt
+
+umount $mnt
+lvchange -an $vg/$lv1
+
 vgremove -ff $vg
 
diff --git a/test/shell/writecache-split.sh b/test/shell/writecache-split.sh
index e615e2a13..d1b14bfd3 100644
--- a/test/shell/writecache-split.sh
+++ b/test/shell/writecache-split.sh
@@ -171,5 +171,51 @@ lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
 fail vgsplit $vg $vg1 "$dev2"
 fail vgsplit $vg $vg1 "$dev3"
 lvremove $vg/$lv1
+vgremove $vg
+
+#
+# uncache
+#
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
+
+# while inactive
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+
+lvchange -ay $vg/$lv1
+mkfs_mount_umount $lv1
+lvchange -an $vg/$lv1
+
+lvconvert --uncache $vg/$lv1
+lvs -o segtype $vg/$lv1 | grep linear
+not lvs $vg/$lv2
+
+lvchange -ay $vg/$lv1
+mount_umount $lv1
+lvchange -an $vg/$lv1
+lvremove -y $vg/$lv1
+
+# while active
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+
+lvchange -ay $vg/$lv1
+mkfs_mount_umount $lv1
+
+lvconvert --uncache $vg/$lv1
+lvs -o segtype $vg/$lv1 | grep linear
+not lvs $vg/$lv2
+
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mount_umount $lv1
+lvchange -an $vg/$lv1
+lvremove -y $vg/$lv1
 
 vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7d5a541d0..432396567 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3662,6 +3662,7 @@ struct lvconvert_result {
 	unsigned need_polling:1;
 	unsigned wait_cleaner_writecache:1;
 	unsigned active_begin:1;
+	unsigned remove_cache:1;
 	struct dm_list poll_idls;
 };
 
@@ -4966,8 +4967,18 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 			return ECMD_FAILED;
 
 		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
-			if (lvremove_single(cmd, lv_fast, NULL) != ECMD_PROCESSED)
-				return ECMD_FAILED;
+			struct lvconvert_result *lr = (struct lvconvert_result *) handle->custom_handle;
+			/*
+			 * If detach is ongoing, then the remove needs to wait
+			 * until _lvconvert_detach_writecache_when_clean(),
+			 * after the detach has finished. When lr->remove_cache
+			 * has been set, when_clean() knows it should remove
+			 * lv_fast at the end.
+			 */
+			if (!lr->wait_cleaner_writecache) {
+				if (lvremove_single(cmd, lv_fast, NULL) != ECMD_PROCESSED)
+					return ECMD_FAILED;
+			}
 		}
 		ret = 1;
 	} else if (lv_is_cache(lv_main) && lv_is_cache_vol(lv_fast)) {
@@ -5637,6 +5648,10 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 		lr->wait_cleaner_writecache = 1;
 		lr->active_begin = active_begin;
 
+		/* The command wants to remove the cache after detaching. */
+		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD)
+			lr->remove_cache = 1;
+
 		dm_list_add(&lr->poll_idls, &idl->list);
 		return 1;
 	}
@@ -5679,6 +5694,7 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 	struct poll_operation_id *id;
 	struct volume_group *vg;
 	struct logical_volume *lv;
+	struct logical_volume *lv_fast;
 	uint32_t lockd_state, error_flags;
 	uint64_t dirty;
 	int ret;
@@ -5759,6 +5775,8 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 
 	log_print("Detaching writecache completed cleaning.");
 
+	lv_fast = first_seg(lv)->writecache;
+
 	/*
 	 * When the cleaner has finished, we can detach with noflush since
 	 * the cleaner has done the flushing.
@@ -5770,6 +5788,17 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 		goto out_release;
 	}
 
+	/*
+	 * The detach was started by an uncache command that wants to remove
+	 * the cachevol after detaching.
+	 */
+	if (lr->remove_cache) {
+		if (lvremove_single(cmd, lv_fast, NULL) != ECMD_PROCESSED) {
+			log_error("Removing the writecache cachevol failed.");
+			ret = 0;
+		}
+	}
+
 	ret = 1;
 	backup(vg);
 


