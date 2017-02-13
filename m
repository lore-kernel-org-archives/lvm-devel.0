From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:09 +0000 (UTC)
Subject: master - lvconvert: add startpoll command using command def
Message-ID: <20170213181009.CE4A960EED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d71aaca07b2c14049130ab368221510c65236af7
Commit:        d71aaca07b2c14049130ab368221510c65236af7
Parent:        fa2a728a395639a32707bb75e6bb4197b02769de
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Dec 19 15:38:03 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: add startpoll command using command def

This is a new explicit version of 'lvconvert LV'
which has been an obscure way of triggering polling
to be restarted on an LV that was previously converted.
---
 test/shell/lvconvert-mirror.sh |   21 ++++++--------
 tools/args.h                   |    1 +
 tools/command-lines.in         |   17 +++++++++---
 tools/lvconvert.c              |   57 ++++++++++++++++++++++++++++++++++++++++
 tools/lvmcmdline.c             |    6 +++-
 tools/tools.h                  |    2 +
 6 files changed, 86 insertions(+), 18 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 1d4fb08..5008f15 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -85,12 +85,9 @@ offset=$(( offset + 2 ))
 # update in case  mirror ever gets faster and allows parallel read
 aux delay_dev "$dev2" 0 2000 ${offset}:1
 lvcreate -aey -l5 -Zn -Wn --type mirror --regionsize 16K -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
-# FIXME: add a new explicit option to define the polling behavior
-# done here with 'lvconvert vg/lv'.  That option can specify
-# that the command succeeds even if the LV doesn't need polling.
 should not lvconvert -m-1 $vg/$lv1 "$dev1"
 aux enable_dev "$dev2"
-should lvconvert $vg/$lv1 # wait
+lvconvert --startpoll $vg/$lv1 || true # wait
 lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should" failed...
 
 aux wait_for_sync $vg $lv1
@@ -116,7 +113,7 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # Next convert should fail b/c we can't have 2 at once
 should not lvconvert -m+1 $vg/$lv1 "$dev5"
 aux enable_dev "$dev4"
-should lvconvert $vg/$lv1 # wait
+lvconvert --startpoll $vg/$lv1 || true # wait
 lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
 
 check mirror $vg $lv1 "$dev3"
@@ -159,7 +156,7 @@ lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 "$dev4"
 lvchange -aey $vg/$lv1
-should lvconvert $vg/$lv1 # wait
+lvconvert --startpoll $vg/$lv1 || true # wait
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 lvremove -ff $vg
@@ -171,7 +168,7 @@ lvremove -ff $vg
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev4"
-should lvconvert $vg/$lv1 # wait
+lvconvert --startpoll $vg/$lv1 || true # wait
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -182,7 +179,7 @@ lvremove -ff $vg
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
 lvconvert -m-1 $vg/$lv1 "$dev4"
-should lvconvert $vg/$lv1 # wait
+lvconvert --startpoll $vg/$lv1 || true # wait
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -195,9 +192,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-should lvconvert $vg/$lv1
+lvconvert --startpoll $vg/$lv1 || true
 lvconvert -m-1 $vg/$lv1 "$dev2"
-should lvconvert $vg/$lv1
+lvconvert --startpoll $vg/$lv1 || true
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -210,9 +207,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-should lvconvert $vg/$lv1
+lvconvert --startpoll $vg/$lv1 || true
 lvconvert -m-1 $vg/$lv1 "$dev2"
-should lvconvert $vg/$lv1
+lvconvert --startpoll $vg/$lv1 || true
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
diff --git a/tools/args.h b/tools/args.h
index a015318..3560c9c 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -118,6 +118,7 @@ arg(splitmirrors_ARG, '\0', "splitmirrors", number_VAL, 0, 0)
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", 0, 0, 0)
 arg(showdeprecated_ARG, '\0', "showdeprecated", 0, 0, 0)
 arg(showunsupported_ARG, '\0', "showunsupported", 0, 0, 0)
+arg(startpoll_ARG, '\0', "startpoll", 0, 0, 0)
 arg(stripes_long_ARG, '\0', "stripes", number_VAL, 0, 0)
 arg(syncaction_ARG, '\0', "syncaction", syncaction_VAL, 0, 0)
 arg(sysinit_ARG, '\0', "sysinit", 0, 0, 0)
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 98623a1..4704747 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -592,13 +592,22 @@ RULE: all not lv_is_locked lv_is_pvmove
 
 ---
 
-# FIXME: add a new option defining this operation, e.g. --poll-mirror
-# The purpose of this command is not entirely clear.
+# This command just (re)starts the polling process on the LV
+# to continue a previous conversion.
 
+lvconvert --startpoll LV_mirror
+OO: OO_LVCONVERT
+ID: lvconvert_start_poll
+DESC: Poll LV to continue conversion.
+RULE: all and lv_is_converting
+
+# alternate form of lvconvert --startpoll, this is only kept
+# for compat since this was how it used to be done.
 lvconvert LV_mirror
 OO: OO_LVCONVERT
-ID: lvconvert_poll_start
-DESC: Poll mirror LV to collapse resync layers.
+ID: lvconvert_start_poll
+DESC: Poll LV to continue conversion.
+RULE: all and lv_is_converting
 FLAGS: SECONDARY_SYNTAX
 
 ---
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9f3a475..b7621b5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5063,3 +5063,60 @@ int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char
 			       NULL, NULL, &_lvconvert_combine_split_snapshot_single);
 }
 
+static int _lvconvert_start_poll_single(struct cmd_context *cmd,
+                                       struct logical_volume *lv,
+                                       struct processing_handle *handle)
+{
+	struct lvconvert_result *lr = (struct lvconvert_result *) handle->custom_handle;
+	struct convert_poll_id_list *idl;
+
+	if (!(idl = _convert_poll_id_list_create(cmd, lv)))
+		return_ECMD_FAILED;
+	dm_list_add(&lr->poll_idls, &idl->list);
+
+	lr->need_polling = 1;
+
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_start_poll_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_result lr = { 0 };
+	struct convert_poll_id_list *idl;
+	int saved_ignore_suspended_devices;
+	int ret, poll_ret;
+
+	dm_list_init(&lr.poll_idls);
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lr;
+
+	saved_ignore_suspended_devices = ignore_suspended_devices();
+	init_ignore_suspended_devices(1);
+
+	cmd->handles_missing_pvs = 1;
+
+	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      handle, NULL, &_lvconvert_start_poll_single);
+
+	init_ignore_suspended_devices(saved_ignore_suspended_devices);
+
+	if (lr.need_polling) {
+		dm_list_iterate_items(idl, &lr.poll_idls) {
+			poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
+						arg_is_set(cmd, background_ARG), 0, 0);
+			if (poll_ret > ret)
+				ret = poll_ret;
+		}
+	}
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e3904d6..83deaf1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -131,7 +131,11 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 	{ lvconvert_split_cow_snapshot_CMD, lvconvert_split_snapshot_cmd },
 	{ lvconvert_merge_snapshot_CMD, lvconvert_merge_snapshot_cmd },
 	{ lvconvert_combine_split_snapshot_CMD, lvconvert_combine_split_snapshot_cmd },
+
+	/* lvconvert utility to trigger polling on an LV. */
+	{ lvconvert_start_poll_CMD, lvconvert_start_poll_cmd },
 };
+
 #if 0
 	/* all raid-related type conversions */
 
@@ -155,8 +159,6 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 	/* other misc. */
 
 	{ lvconvert_merge_CMD,				lvconvert_merge_fn },
-	{ lvconvert_poll_start_CMD,			lvconvert_poll_start_fn },
-
 #endif
 
 /* Command line args */
diff --git a/tools/tools.h b/tools/tools.h
index 8ac98e8..a152fcf 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -258,4 +258,6 @@ int lvconvert_merge_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv)
 int lvconvert_split_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvconvert_start_poll_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 #endif


