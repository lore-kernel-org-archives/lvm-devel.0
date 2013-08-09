From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri,  9 Aug 2013 22:10:52 +0000 (UTC)
Subject: master - RAID: Fix bug making lvchange unable to change recovery rate for RAID
Message-ID: <20130809221052.9724F60FE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8615234c0fa331852a11e1bf595bf1d4b858f4bc
Commit:        8615234c0fa331852a11e1bf595bf1d4b858f4bc
Parent:        a1dc585fa655a0d6da278fba4b9e249b4a7193ce
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 9 17:09:47 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Aug 9 17:09:47 2013 -0500

RAID: Fix bug making lvchange unable to change recovery rate for RAID

1) Since the min|maxrecoveryrate args are size_kb_ARGs and they
   are recorded (and sent to the kernel) in terms of kB/sec/disk,
   we must back out the factor multiple done by size_kb_arg.  This
   is already performed by 'lvcreate' for these arguments.
2) Allow all RAID types, not just RAID1, to change these values.
3) Add min|maxrecoveryrate_ARG to the list of 'update_partial_unsafe'
   commands so that lvchange will not complain about needing at
   least one of a certain set of arguments and failing.
4) Add tests that check that these values can be set via lvchange
   and lvcreate and that 'lvs' reports back the proper results.
---
 WHATS_NEW                     |    1 +
 test/shell/lvchange-raid.sh   |   17 +++++++++++++++++
 test/shell/lvcreate-raid.sh   |   23 +++++++++++++++++++++++
 test/shell/lvcreate-raid10.sh |    9 +++++++++
 tools/lvchange.c              |    4 +++-
 5 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d2830ee..6b65281 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Fix bug making lvchange unable to change recovery rate for RAID.
   Prohibit convertion of thin pool to external origin.
   Workaround gcc v4.8 -O2 bug causing failures if config/checks=1 (32bit arch).
   Verify clvmd message validity before processing and log error if incorrect.
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 2e62312..715df15 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -214,6 +214,19 @@ run_refresh_check() {
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
 }
 
+# run_recovery_rate_check <VG> <LV>
+#   Assumes "$dev2" is in the array
+run_recovery_rate_check() {
+	printf "#\n#\n#\n# %s/%s (%s): run_recovery_rate_check\n#\n#\n#\n" \
+		$1 $2 `lvs --noheadings -o segtype $1/$2`
+
+	lvchange --minrecoveryrate 50 $1/$2
+	lvchange --maxrecoveryrate 100 $1/$2
+
+	[ `lvs --noheadings -o raid_min_recovery_rate $1/$2` == "50" ]
+	[ `lvs --noheadings -o raid_max_recovery_rate $1/$2` == "100" ]
+}
+
 # run_checks <VG> <LV> [snapshot_dev]
 run_checks() {
 	# Without snapshots
@@ -223,6 +236,8 @@ run_checks() {
 
 	run_refresh_check $1 $2
 
+	run_recovery_rate_check $1 $2
+
 	# With snapshots
 	if [ ! -z $3 ]; then
 		lvcreate -s $1/$2 -l 4 -n snap $3
@@ -233,6 +248,8 @@ run_checks() {
 
 		run_refresh_check $1 $2
 
+		run_recovery_rate_check $1 $2
+
 		lvremove -ff $1/snap
 	fi
 }
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 634c518..ee56b9c 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -38,6 +38,15 @@ lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
 lvremove -ff $vg
 
+# Create RAID1 (explicit 3-way) - Set min/max recovery rate
+lvcreate --type raid1 -m 2 -l 2 \
+	--minrecoveryrate 50 --maxrecoveryrate 100 \
+	-n $lv1 $vg
+[ `lvs --noheadings -o raid_min_recovery_rate $vg/$lv1` -eq 50 ]
+[ `lvs --noheadings -o raid_max_recovery_rate $vg/$lv1` -eq 100 ]
+aux wait_for_sync $vg $lv1
+lvremove -ff $vg
+
 # Create RAID 4/5/6 (explicit 3-stripe + parity devs)
 for i in raid4 \
 	raid5 raid5_ls raid5_la raid5_rs raid5_ra \
@@ -47,3 +56,17 @@ for i in raid4 \
 	aux wait_for_sync $vg $lv1
 	lvremove -ff $vg
 done
+
+# Create RAID 4/5/6 (explicit 3-stripe + parity devs) - Set min/max recovery
+for i in raid4 \
+	raid5 raid5_ls raid5_la raid5_rs raid5_ra \
+	raid6 raid6_zr raid6_nr raid6_nc; do
+
+	lvcreate --type $i -l 3 -i 3 \
+		--minrecoveryrate 50 --maxrecoveryrate 100 \
+		-n $lv1 $vg
+	[ `lvs --noheadings -o raid_min_recovery_rate $vg/$lv1` -eq 50 ]
+	[ `lvs --noheadings -o raid_max_recovery_rate $vg/$lv1` -eq 100 ]
+	aux wait_for_sync $vg $lv1
+	lvremove -ff $vg
+done
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 830b390..933097a 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -30,6 +30,15 @@ not lvcreate --type raid10 -m 2 -i 2 -l 2 -n $lv1 $vg
 # 2-way mirror, 2-stripes
 lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
+lvremove -ff $vg/$lv1
+
+# 2-way mirror, 2-stripes - Set min/max recovery rate
+lvcreate --type raid10 -m 1 -i 2 -l 2 \
+	--minrecoveryrate 50 --maxrecoveryrate 100 \
+	-n $lv1 $vg
+[ `lvs --noheadings -o raid_min_recovery_rate $vg/$lv1` -eq 50 ]
+[ `lvs --noheadings -o raid_max_recovery_rate $vg/$lv1` -eq 100 ]
+aux wait_for_sync $vg $lv1
 
 # 2-way mirror, 3-stripes
 lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv2 $vg
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3ba78e6..4973406 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1143,9 +1143,11 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, detachprofile_ARG) ||
 		arg_count(cmd, setactivationskip_ARG);
 	int update_partial_unsafe =
-		arg_count(cmd, resync_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, discards_ARG) ||
+		arg_count(cmd, resync_ARG) ||
+		arg_count(cmd, raidminrecoveryrate_ARG) ||
+		arg_count(cmd, raidmaxrecoveryrate_ARG) ||
 		arg_count(cmd, syncaction_ARG) ||
 		arg_count(cmd, writebehind_ARG) ||
 		arg_count(cmd, writemostly_ARG) ||


