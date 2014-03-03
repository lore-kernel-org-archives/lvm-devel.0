From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Mar 2014 10:24:54 +0000 (UTC)
Subject: master - tests: split raid test
Message-ID: <20140303102454.430FD603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52007a9191e67b9b6d83fcf8332aceaa4e0f5e48
Commit:        52007a9191e67b9b6d83fcf8332aceaa4e0f5e48
Parent:        a92fae079be1486302343443a813df9ec5bfd2ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 3 11:20:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 3 11:23:57 2014 +0100

tests: split raid test

Use separate files for raid1, raid456, raid10.
They need different target versions to work, so support
more precise test selection.

Optimize duplicate tests of target avalability and skip
unsupported test cases sooner.
---
 test/shell/lvchange-raid.sh    |   61 ++++++++++++++--------------------------
 test/shell/lvchange-raid10.sh  |   20 +++++++++++++
 test/shell/lvchange-raid456.sh |   22 ++++++++++++++
 3 files changed, 63 insertions(+), 40 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 84c47f2..8fc91a3 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -11,8 +11,6 @@
 
 . lib/test
 
-THIN_POSTFIX=""
-
 # Writemostly has been in every version since the begining
 # Device refresh in 1.5.1 upstream and 1.3.4 < x < 1.4.0 in RHEL6
 # Sync action    in 1.5.0 upstream and 1.3.3 < x < 1.4.0 in RHEL6
@@ -252,7 +250,7 @@ run_recovery_rate_check() {
 	local vg=$1
 	local lv=${2}${THIN_POSTFIX}
 
-	printf "#\n#\n#\n# %s/%s %s: run_recovery_rate_check\n#\n#\n#\n" \
+	printf "#\n#\n#\n# %s/%s (%s): run_recovery_rate_check\n#\n#\n#\n" \
 		 $vg $lv $(get lv_field $vg/$lv segtype -a)
 	lvchange --minrecoveryrate 50 $vg/$lv
 	lvchange --maxrecoveryrate 100 $vg/$lv
@@ -276,13 +274,6 @@ run_checks() {
 		run_refresh_check $1 $2
 		run_recovery_rate_check $1 $2
 	elif [ 'thinpool_data' == $3 ]; then
-		aux have_thin 1 8 0 || return 0
-
-		# RAID works EX in cluster
-		# thinpool works EX in cluster
-		# but they don't work together in a cluster yet
-		#  (nor does thinpool+mirror work in a cluster yet)
-		test -e LOCAL_CLVMD && return 0
 		printf "#\n#\n# run_checks: RAID as thinpool data\n#\n#\n"
 
 # Hey, specifying devices for thin allocation doesn't work
@@ -297,8 +288,6 @@ run_checks() {
 		run_refresh_check $1 $2
 		run_recovery_rate_check $1 $2
 	elif [ 'thinpool_meta' == $3 ]; then
-		aux have_thin 1 8 0 || return 0
-		test -e LOCAL_CLVMD && return 0
 		printf "#\n#\n# run_checks: RAID as thinpool metadata\n#\n#\n"
 
 		lvrename $1/$2 ${2}_meta
@@ -327,35 +316,27 @@ run_checks() {
 	fi
 }
 
+run_types() {
+	for i in $TEST_TYPES ; do
+		lvcreate -n $lv1 $vg -L2M --type "$@"
+		run_checks $vg $lv1 $i
+		lvremove -ff $vg
+	done
+}
+
 ########################################################
 # MAIN
 ########################################################
 
-for i in "-" "snapshot" "thinpool_data" "thinpool_meta"; do
-	lvcreate --type raid1 -m 1 -L 2M -n $lv1 $vg \
-			"$dev1" "$dev2"
-	run_checks $vg $lv1 $i
-	lvremove -ff $vg
-
-	lvcreate --type raid4 -i 2 -L 2M -n $lv1 $vg \
-			"$dev1" "$dev2" "$dev3" "$dev4"
-	run_checks $vg $lv1 $i
-	lvremove -ff $vg
-
-	lvcreate --type raid5 -i 2 -L 2M -n $lv1 $vg \
-			"$dev1" "$dev2" "$dev3" "$dev4"
-	run_checks $vg $lv1 $i
-	lvremove -ff $vg
-
-	lvcreate --type raid6 -i 3 -L 2M -n $lv1 $vg \
-			"$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	run_checks $vg $lv1 $i
-	lvremove -ff $vg
-
-	lvcreate --type raid10 -m 1 -i 2 -L 2M -n $lv1 $vg \
-			"$dev1" "$dev2" "$dev3" "$dev4"
-	run_checks $vg $lv1 $i
-	lvremove -ff $vg
-done
-
-vgremove -ff $vg
+TEST_TYPES="- snapshot"
+# RAID works EX in cluster
+# thinpool works EX in cluster
+# but they don't work together in a cluster yet
+#  (nor does thinpool+mirror work in a cluster yet)
+test ! -e LOCAL_CLVMD -a aux have_thin 1 8 0 && TEST_TYPE="$TEST_TYPES thinpool_data thinpool_meta"
+
+# Implicit test for 'raid1' only
+if test "${TEST_RAID:-raid1}" = raid1 ; then
+	run_types raid1 -m 1 "$dev1" "$dev2"
+	vgremove -ff $vg
+fi
diff --git a/test/shell/lvchange-raid10.sh b/test/shell/lvchange-raid10.sh
new file mode 100644
index 0000000..b31c328
--- /dev/null
+++ b/test/shell/lvchange-raid10.sh
@@ -0,0 +1,20 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+TEST_RAID=raid10
+
+. shell/lvchange-raid.sh
+
+aux target_at_least dm-raid 1 5 2 || skip
+
+run_types raid10 -m 1 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
+
+vgremove -ff $vg
diff --git a/test/shell/lvchange-raid456.sh b/test/shell/lvchange-raid456.sh
new file mode 100644
index 0000000..41a0dfd
--- /dev/null
+++ b/test/shell/lvchange-raid456.sh
@@ -0,0 +1,22 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+TEST_RAID=raid456
+
+. shell/lvchange-raid.sh
+
+aux target_at_least dm-raid 1 5 2 || skip
+
+run_types raid4 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
+run_types raid5 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
+run_types raid6 -i 3 "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+
+vgremove -ff $vg


