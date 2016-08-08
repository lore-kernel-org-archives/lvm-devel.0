From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon,  8 Aug 2016 11:53:17 +0000 (UTC)
Subject: master - lvcreate: reject '--nosync' option for RAID6 LVs
Message-ID: <20160808115317.92DF760FA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d6cf12554b0b6cbbee9db2f4da9439d6492a2b3
Commit:        7d6cf12554b0b6cbbee9db2f4da9439d6492a2b3
Parent:        57fa5d4329e9152ff689b510f16a237e2f85c903
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Aug 8 13:52:35 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Aug 8 13:52:35 2016 +0200

lvcreate: reject '--nosync' option for RAID6 LVs

The MD raid6 personality being used to drive lvm raid6 LVs does
read-modify-write updates to any stripes and thus relies on correct
P and Q Syndromes being written during initial synchronization or
it may fail reconstructing proper user data in case of SubLVs failing.

We may not allow the '--nosync' option on
creation of raid6 LVs for that reason.

Update/fix 'man lvcreate' in that regard.

add lvcreate-raid-nosync.sh test script.

- Resolves rhbz1358532
---
 man/lvcreate.8.in                  |   29 ++++++++++---
 test/shell/lvcreate-raid-nosync.sh |   85 ++++++++++++++++++++++++++++++++++++
 tools/lvcreate.c                   |    5 ++-
 3 files changed, 112 insertions(+), 7 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 34b6523..2873e72 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -381,10 +381,11 @@ would result in a mirror with two-sides; that is,
 a linear volume plus one copy.
 
 Specifying the optional argument \fB\-\-nosync\fP will cause the creation
-of the mirror to skip the initial resynchronization.  Any data written
-afterwards will be mirrored, but the original contents will not be
-copied.  This is useful for skipping a potentially long and resource
-intensive initial sync of an empty device.
+of the mirror LV to skip the initial resynchronization.  Any data written
+afterwards will be mirrored, but the original contents will not be copied.
+
+This is useful for skipping a potentially long and resource intensive initial
+sync of an empty mirrored RaidLV.
 
 There are two implementations of mirroring which can be used and correspond
 to the "\fIraid1\fP" and "\fImirror\fP" segment types.
@@ -440,7 +441,21 @@ Without this option a default name of "lvol#" will be generated where
 .HP
 .BR \-\-nosync
 .br
-Causes the creation of the mirror to skip the initial resynchronization.
+Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
+initial resynchronization.  In case of mirror, raid1 and raid10, any data
+written afterwards will be mirrored, but the original contents will not be
+copied.  In case of raid4 and raid5, no parity blocks will be written,
+though any data written afterwards will cause parity blocks to be stored.
+.br
+This is useful for skipping a potentially long and resource intensive initial
+sync of an empty mirror/raid1/raid4/raid5 and raid10 LV.
+.br
+This option is not valid for raid6, because raid6 relies on proper parity
+(P and Q Syndromes) being created during initial synchronization in order
+to reconstruct proper user date in case of device failures.
+
+raid0 and raid0_meta don't provide any data copies or parity support
+and thus don't support initial resynchronization.
 .
 .HP
 .BR \-\-noudevsync
@@ -621,12 +636,14 @@ to the command.
 .br
 Note the current limitation of 8 stripes total in any RaidLV including parity devices.
 
+See the \fB\-\-nosync\fP option to optionally avoid initial syncrhonization of RaidLVs.
+
 Two implementations of basic striping are available in the kernel.
 The original device-mapper implementation is the default and should
 normally be used.  The alternative implementation using MD, available
 since version 1.7 of the RAID device-mapper kernel target (kernel
 version 4.2) is provided to facilitate the development of new RAID
-features.  It may be accessed with \fB--type raid0\fP, but is best
+features.  It may be accessed with \fB--type raid0[_meta]\fP, but is best
 avoided at present because of assorted restrictions on resizing and converting
 such devices.
 .HP
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
new file mode 100644
index 0000000..4c6da46
--- /dev/null
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -0,0 +1,85 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_raid 1 7 0 || skip
+
+aux prepare_vg 6
+
+
+# Delay 1st leg so that rebuilding status characters
+#  can be read before resync finished too quick.
+aux delay_dev "$dev1" 0 1
+
+# raid0/raid0_meta don't support resynchronization
+for r in raid0 raid0_meta
+do
+	lvcreate --yes --type raid0 -i 3 -l 1 -n $lv1 $vg
+	aux check_status_chars $vg $lv1 "AAA"
+	lvremove --yes $vg/$lv1
+done
+
+# raid1 supports resynchronization
+lvcreate --yes --type raid1 -m 2 -l 1 -n $lv1 $vg
+aux check_status_chars $vg $lv1 "aaa"
+aux wait_for_sync $vg $lv1
+aux check_status_chars $vg $lv1 "AAA"
+lvremove --yes $vg/$lv1
+
+# raid1 supports --nosync
+lvcreate --yes --type raid1 --nosync -m 2 -l 1 -n $lv1 $vg
+aux check_status_chars $vg $lv1 "AAA"
+lvremove --yes $vg/$lv1
+
+for r in raid4 raid5
+do 
+	# raid4/5 support resynchronization
+	lvcreate --yes --type $r -i 3 -l 1 -n $lv1 $vg
+	aux check_status_chars $vg $lv1 "aaaa"
+	aux wait_for_sync $vg $lv1
+	aux check_status_chars $vg $lv1 "AAAA"
+	lvremove --yes $vg/$lv1
+
+	# raid4/5 support --nosync
+	lvcreate --yes --type $r --nosync -i 3 -l 1 -n $lv1 $vg
+	aux check_status_chars $vg $lv1 "AAAA"
+	lvremove --yes $vg/$lv1
+done
+
+# raid6 supports resynchronization
+lvcreate --yes --type raid6 -i 3 -l 1 -n $lv1 $vg
+aux check_status_chars $vg $lv1 "aaaaa"
+aux wait_for_sync $vg $lv1
+aux check_status_chars $vg $lv1 "AAAAA"
+lvremove --yes $vg/$lv1
+
+# raid6 rejects --nosync; it has to initialize P- and Q-Syndromes
+not lvcreate --yes --type raid6 --nosync -i 3 -l 1 -n $lv1 $vg
+
+# raid10 supports resynchronization
+lvcreate --yes --type raid10 -m 1 -i 3 -l 1 -n $lv1 $vg
+aux check_status_chars $vg $lv1 "aaaaaa"
+aux wait_for_sync $vg $lv1
+aux check_status_chars $vg $lv1 "AAAAAA"
+aux wait_for_sync $vg $lv1
+lvremove --yes $vg/$lv1
+
+# raid10 supports --nosync
+lvcreate --yes --type raid10 --nosync -m 1 -i 3 -l 1 -n $lv1 $vg
+aux check_status_chars $vg $lv1 "AAAAAA"
+aux wait_for_sync $vg $lv1
+lvremove --yes $vg/$lv1
+
+vgremove -ff $vg
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 253fab8..28d8c92 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -562,7 +562,10 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	lp->nosync = arg_is_set(cmd, nosync_ARG);
+	if ((lp->nosync = arg_is_set(cmd, nosync_ARG)) && seg_is_any_raid6(lp)) {
+		log_error("nosync option prohibited on RAID6");
+		return 0;
+	}
 
 	if (!(lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0)) &&
 	    ((lp->region_size = get_default_region_size(cmd)) <= 0)) {


