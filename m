From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  9 Sep 2020 13:17:52 +0000 (GMT)
Subject: master - man: correcting vdo issues
Message-ID: <20200909131752.B8A7D3857C6C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0210c7076d0db2fc835ed11a86a901c725096e6f
Commit:        0210c7076d0db2fc835ed11a86a901c725096e6f
Parent:        763342016c2ca408bc3505ea4a14d0d22c610839
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 9 15:14:22 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 9 15:16:34 2020 +0200

man: correcting vdo issues

Fixing reported bugs within provided examples - so examples
can be used via cut&paste.
---
 WHATS_NEW         |  1 +
 man/lvmvdo.7_main | 11 ++++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1fffbb5d7..8f33c8ae4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Improving VDO man page examples.
   Switch code base to use flexible array syntax.
   Fix 64bit math when calculation cachevol size.
   Preserve uint32_t for seqno handling.
diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index ab9a27811..76a758061 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -138,14 +138,15 @@ that can keep 100% uncompressible data there.
 
 VDO allows to set large variety of options. Lots of these settings
 can be specified by lvm.conf or profile settings. User can prepare
-number of different profiles and just specify profile file name.
+number of different profiles in #DEFAULT_SYS_DIR#/profile directory
+and just specify profile file name.
 Check output of \fBlvmconfig --type full\fP for detailed description
 of all individual vdo settings.
 
 .I Example
 .br
 .nf
-# cat <<EOF > vdo.profile
+# cat <<EOF > #DEFAULT_SYS_DIR#/profile/vdo_create.profile
 allocation {
 	vdo_use_compression=1
 	vdo_use_deduplication=1
@@ -169,7 +170,7 @@ allocation {
 }
 EOF
 
-# lvcreate --vdo -L10G --metadataprofile vdo.profile vg/vdopool0
+# lvcreate --vdo -L10G --metadataprofile vdo_create vg/vdopool0
 # lvcreate --vdo -L10G --config 'allocation/vdo_cpu_threads=4' vg/vdopool1
 .fi
 
@@ -211,7 +212,7 @@ Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
   vdopool0         vg dwi-ao---- 10.00g                 30.16
   [vdopool0_vdata] vg Dwi-ao---- 10.00g
 
-# vdostats --all /dev/mapper/vg-vdopool0
+# vdostats --all /dev/mapper/vg-vdopool0-vpool
 /dev/mapper/vg-vdopool0 :
   version                             : 30
   release version                     : 133524
@@ -306,7 +307,7 @@ resize will not work).
 .I Example
 .br
 .nf
-# lvcreate -L 5G -V 10G -n vdo1 vg/vpool
+# lvcreate --type vdo -L 5G -V 10G -n vdo1 vg/vpool
 # lvcreate --type cache-pool -L 1G -n cpool vg
 # lvconvert --cache --cachepool vg/cpool vg/vpool
 # lvconvert --uncache vg/vpool


