From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Sep 2019 12:40:07 -0400
Subject: master - tests: update duplicate md tests
Message-ID: <201909301640.x8UGe759024806@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bfae5bf8e5905a72f7168562e1bbc074f23b791
Commit:        1bfae5bf8e5905a72f7168562e1bbc074f23b791
Parent:        f836fe3836e990e41b2c2b59c2af7ef6b979097f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 27 14:18:35 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 30 11:38:10 2019 -0500

tests: update duplicate md tests

adjust to recent improvements in duplicate handling
---
 test/shell/duplicate-pvs-md1.sh |   39 ++++++++++++++-------------------------
 1 files changed, 14 insertions(+), 25 deletions(-)

diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index 626c55c..334ac41 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -190,18 +190,17 @@ lvs -o active $vg |tee out || true
 grep "active" out
 vgchange -an $vg
 
-# N.B. when the md dev (which is started) has not been scanned by
-# pvscan, then pvscan --cache on the md component does not detect it's
-# an md component, and marks the PVID online, then does activation,
-# but the activation using the component fails because the component
-# device is busy from being used in the md dev, and activation fails.
-# The default behavior in auto mode is preferrable.
+# The dev name and device_hint don't match so pvscan
+# skips quick activation and scans all devs during
+# activation.  This means it sees the component and
+# the mddev as duplicates and chooses to use the mddev
+# for activation.
 _clear_online_files
-not pvscan --cache -aay "$dev1"
+pvscan --cache -aay "$dev1"
 ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
 lvs -o active $vg |tee out || true
-not grep "active" out
+grep "active" out
 
 # pvscan activation from mddev first, then try from component which fails
 _clear_online_files
@@ -332,27 +331,17 @@ pvscan --cache -aay
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
+# component dev name does not match device_hint in metadata so
+# quick activation is skipped and activation scans all devs.
+# this leads it to see both components as duplicates which
+# triggers full md check which means we see both devs are
+# md components and drop them, leaving no remaining devs
+# on which this vg is seen.
 _clear_online_files
-pvscan --cache -aay "$dev1"
+not pvscan --cache -aay "$dev1"
 ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
 
-# N.B. not good to activate from component, but result of "start" setting
-# Other commands will not see the vg at this point because they'll
-# recognize the md components and ignore them (where pvscan is special due
-# to it not scanning all devs and not seeing the duplicates and not
-# detecting the components.)
-# disable dev2 so other cmds don't see dups and we can deactivate the vg
-aux disable_dev "$dev2"
-vgchange -an $vg
-
-aux enable_dev "$dev2"
-aux udev_wait
-cat /proc/mdstat
-# for some reason enabling dev2 starts an odd md dev
-mdadm --stop "$mddev" || true
-mdadm --stop --scan
-cat /proc/mdstat
 wipefs -a "$dev1" || true
 wipefs -a "$dev2" || true
 


