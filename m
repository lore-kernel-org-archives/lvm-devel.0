From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Dec 2014 13:02:14 +0000 (UTC)
Subject: master - vgimportclone: also notify lvmetad about changes if it's used
Message-ID: <20141210130214.259F460C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b21a8412c482ae735d0d044d355e1541ccba6edf
Commit:        b21a8412c482ae735d0d044d355e1541ccba6edf
Parent:        00b36ef06acb15c82d7c9b37872753f02c638316
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 10 13:43:54 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 10 14:00:56 2014 +0100

vgimportclone: also notify lvmetad about changes if it's used

All the LVM commands are run in mode without lvmetad use (since lvmetad
can't handle duplicates). When we're finished with vgimportclone, we
need to notify lvmetad about changes.

Before this patch (/dev/sda and /dev/sdb contains a copy VG called "vg"):
$ vgimportclone --basevgname vg_snap /dev/sdb
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  WARNING: Activation disabled. No device-mapper interaction will be attempted.
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  Physical volume "/tmp/snap.zcJ8LCmj/vgimport0" changed  1 physical volume changed / 0 physical volumes not changed
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  WARNING: Activation disabled. No device-mapper interaction will be attempted.
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  Volume group "vg" successfully changed
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  Volume group "vg" successfully renamed to "vg_snap"
  Reading all physical volumes.  This may take a while...
  Found volume group "vg" using metadata type lvm2
  Found volume group "fedora" using metadata type lvm2

$ vgs
  VG     #PV #LV #SN Attr   VSize   VFree
  fedora   1   2   0 wz--n-   9.50g      0
  vg       1   1   0 wz--n- 124.00m 120.00m

(...lvmetad doesn't see the new "vg_snap"!)

With this patch applied:
$ vgimportclone --basevgname vg_snap /dev/sdb
  ...
  WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!
  Volume group "vg" successfully renamed to "vg_snap"
Notifying lvmetad about changes since it was disabled temporarily.
  Reading all physical volumes.  This may take a while...
  Found volume group "vg_snap" using metadata type lvm2
  Found volume group "fedora" using metadata type lvm2
  Found volume group "vg" using metadata type lvm2

$ vgs
  VG      #PV #LV #SN Attr   VSize   VFree
  fedora    1   2   0 wz--n-   9.50g      0
  vg        1   1   0 wz--n- 124.00m 120.00m
  vg_snap   1   1   0 wz--n- 124.00m 120.00m

The "restart lvmetad before enabling it" message is a bit misleading
here - we should probably suppress this one, but we can't suppress
warning messages selectively at the moment and we don't want to lose
other warning/error messages printed...
---
 WHATS_NEW                |    1 +
 scripts/vgimportclone.sh |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 72d3b6a..5e1b143 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Fix vgimportclone to notify lvmetad about changes done if lvmetad is used.
   Fix vgimportclone to properly override config if it is missing in lvm.conf.
   Fix automatic use of configure --enable-udev-systemd-background-jobs.
   Correctly rename active split LV with -splitmirrors for raid1.
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index bfff131..719cd8d 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -363,6 +363,15 @@ fi
 ### the device nodes we need are straight
 if [ ${CHANGES_MADE} -eq 1 ]
 then
+    # get global/use_lvmetad config and if set also notify lvmetad about changes
+    # since we were running LVM commands above with use_lvmetad=0
+    eval $(${LVM} dumpconfig ${LVM_OPTS} global/use_lvmetad)
+    if [ "$use_lvmetad" = "1" ]
+    then
+      echo "Notifying lvmetad about changes since it was disabled temporarily."
+      LVM_OPTS="${LVM_OPTS} --cache"
+    fi
+
     "$LVM" vgscan ${LVM_OPTS} --mknodes
 fi
 


