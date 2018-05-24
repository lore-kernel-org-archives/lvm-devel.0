From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 10:03:27 -0400
Subject: master - tests: improve usability on older systems
Message-ID: <201805241403.w4OE3RPq012099@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3702f39ef3e1bb7811427df3fe92235890228fc0
Commit:        3702f39ef3e1bb7811427df3fe92235890228fc0
Parent:        d6f244599623ef547fe2c5f70e21abf4cce9a49d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 24 15:20:22 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 24 16:02:31 2018 +0200

tests: improve usability on older systems

---
 test/shell/pvcreate-md-fake-hdr.sh |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index acd6785..50a5b14 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -33,7 +33,7 @@ aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
 
 mddev=$(< MD_DEV)
 pvdev=$(< MD_DEV_PV)
-
+sleep 3
 mdadm --stop "$mddev"
 
 # copy fake PV/VG header PV3 -> PV2 (which is however md raid1 leg)
@@ -52,7 +52,7 @@ sleep 3
 # print what  blkid thinks about each PV
 for i in "$dev1" "$dev2" "$dev3" "$dev4"
 do
-   blkid "$i"
+	blkid -c /dev/null -w /dev/null "$i" || echo "Unknown signature"
 done
 
 # expect open count for each PV to be 0
@@ -74,20 +74,21 @@ sleep 3
 dmsetup info -c
 
 # if for any reason array went up - stop it again
-mdadm --detail "$mddev" && {
+if mdadm --detail "$mddev" ; then
 	mdadm --stop "$mddev"
 	aux udev_wait
 	should not mdadm --detail "$mddev"
-}
+fi
 
-# now reassemble array from  PV1 & PV2 
+# now reassemble array from  PV1 & PV2
 mdadm --assemble --verbose "$mddev" "$dev1" "$dev2"
 aux udev_wait
 sleep 1
 
 # and let 'fake hdr' to be fixed from master/primary leg
-mdadm --action=repair "$mddev"
-sleep 1
-
-# should be showing correctly PV3 & PV4
-pvs
+# (when mdadm supports repair)
+if mdadm --action=repair "$mddev" ; then
+	sleep 1
+	# should be showing correctly PV3 & PV4
+	pvs
+fi


