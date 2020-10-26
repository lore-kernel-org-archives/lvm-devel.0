From: David Teigland <teigland@sourceware.org>
Date: Mon, 26 Oct 2020 19:35:37 +0000 (GMT)
Subject: master - lvchange: allow syncaction check with integrity
Message-ID: <20201026193537.3C5363851C3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=830c20d33cc8253c397e927291d51c249c2c0eb3
Commit:        830c20d33cc8253c397e927291d51c249c2c0eb3
Parent:        2c319398274b930a38278e635e9171ce663f2bab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 26 12:27:18 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 26 14:16:33 2020 -0500

lvchange: allow syncaction check with integrity

syncaction check will detect and correct integrity checksum mismatches.
---
 test/shell/integrity.sh | 151 ++++++++++++++++++++++++++++++++++++++++++++----
 tools/lvchange.c        |   8 ++-
 2 files changed, 146 insertions(+), 13 deletions(-)

diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 7b119965b..7dd237b93 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -96,7 +96,7 @@ _test_fs_with_error() {
 	umount $mnt
 }
 
-_test_fs_with_raid() {
+_test_fs_with_read_repair() {
 	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
@@ -143,6 +143,56 @@ _test_fs_with_raid() {
 	umount $mnt
 }
 
+_test_fs_with_syncaction_check() {
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# add original data
+	cp fileA $mnt
+	cp fileB $mnt
+	cp fileC $mnt
+
+	umount $mnt
+	lvchange -an $vg/$lv1
+
+	# FIXME: this is only finding/corrupting the bit with raid1
+	# other raid levels may require looking at a different dev.
+	# (Attempt this xxd/tac/sed/xxd on each dev in the LV?)
+
+	xxd "$dev1" > dev1.txt
+	tac dev1.txt > dev1.rev
+	rm -f dev1.txt
+	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
+	rm -f dev1.rev
+	tac dev1.rev.bad > dev1.bad
+	rm -f dev1.rev.bad
+	xxd -r dev1.bad > "$dev1"
+	rm -f dev1.bad
+
+	lvchange -ay $vg/$lv1
+
+	lvchange --syncaction check $vg/$lv1
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# read complete fileA which was not corrupted
+	dd if=$mnt/fileA of=tmp bs=1k
+	ls -l tmp
+	stat -c %s tmp | grep 16384
+	cmp -b fileA tmp
+	rm tmp
+
+	# read complete fileB
+	dd if=$mnt/fileB of=tmp bs=1k
+	ls -l tmp
+	stat -c %s tmp | grep 16384
+	cmp -b fileB tmp
+	rm tmp
+
+	umount $mnt
+}
+
 _add_new_data_to_mnt() {
 	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
@@ -235,7 +285,7 @@ _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
-_test_fs_with_raid
+_test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvchange -an $vg/$lv1
@@ -248,10 +298,89 @@ lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
-_test_fs_with_raid
+_test_fs_with_read_repair
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_test_fs_with_read_repair
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_test_fs_with_read_repair
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+_wait_recalc $vg/${lv1}_rimage_4
+_test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvs -o integritymismatches $vg/${lv1}_rimage_3
+lvs -o integritymismatches $vg/${lv1}_rimage_4
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+_test_fs_with_read_repair
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvs -o integritymismatches $vg/${lv1}_rimage_3
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test corrupting data on an image and verifying that
+# it is detected and corrected using syncaction check
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_test_fs_with_syncaction_check
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+check lv_field $vg/${lv1}_rimage_0 integritymismatches "1"
+check lv_field $vg/${lv1}_rimage_1 integritymismatches "0"
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -262,10 +391,13 @@ lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
-_test_fs_with_raid
+_test_fs_with_syncaction_check
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
+check lv_field $vg/${lv1}_rimage_0 integritymismatches "2"
+check lv_field $vg/${lv1}_rimage_1 integritymismatches "0"
+check lv_field $vg/${lv1}_rimage_2 integritymismatches "0"
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -276,7 +408,7 @@ lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
-_test_fs_with_raid
+_test_fs_with_syncaction_check
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
@@ -292,7 +424,7 @@ _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
 _wait_recalc $vg/${lv1}_rimage_4
-_test_fs_with_raid
+_test_fs_with_syncaction_check
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
@@ -309,7 +441,7 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
-_test_fs_with_raid
+_test_fs_with_syncaction_check
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
@@ -621,7 +753,6 @@ _add_new_data_to_mnt
 not lvconvert -y -m-1 $vg/$lv1
 not lvconvert --splitmirrors 1 -n tmp -y $vg/$lv1
 not lvconvert --splitmirrors 1 --trackchanges -y $vg/$lv1
-not lvchange --syncaction check $vg/$lv1
 not lvchange --syncaction repair $vg/$lv1
 not lvreduce -L4M $vg/$lv1
 not lvcreate -s -n snap -L4M $vg/$lv1
@@ -638,7 +769,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
-_test_fs_with_raid
+_test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvchange -an $vg/$lv1
@@ -648,7 +779,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
-_test_fs_with_raid
+_test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
diff --git a/tools/lvchange.c b/tools/lvchange.c
index c0adadf8d..f9a0b54e3 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1658,8 +1658,10 @@ static int _lvchange_syncaction_single(struct cmd_context *cmd,
 				       struct logical_volume *lv,
 				       struct processing_handle *handle)
 {
-	if (lv_raid_has_integrity(lv)) {
-		log_error("Integrity must be removed to use syncaction commands.");
+	const char *msg = arg_str_value(cmd, syncaction_ARG, NULL);
+
+	if (lv_raid_has_integrity(lv) && !strcmp(msg, "repair")) {
+		log_error("Use syncaction check to detect and correct integrity checksum mismatches.");
 		return_ECMD_FAILED;
 	}
 
@@ -1667,7 +1669,7 @@ static int _lvchange_syncaction_single(struct cmd_context *cmd,
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		return_ECMD_FAILED;
 
-	if (!lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL)))
+	if (!lv_raid_message(lv, msg))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;


