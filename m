From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 23:06:41 +0000 (UTC)
Subject: master - tests: cover code from more commands
Message-ID: <20140325230641.E5E9761055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1259ae59540b3e9c5ef582a6e472e17258ee36dc
Commit:        1259ae59540b3e9c5ef582a6e472e17258ee36dc
Parent:        4b30863e857aa5a671485227c9b7a7e3a6d1e277
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 23:55:45 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 00:05:46 2014 +0100

tests: cover code from more commands

---
 test/shell/covercmd.sh |   36 +++++++++++++++++++++++++++++++++---
 1 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index ad7f480..54fe192 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -27,11 +27,14 @@ pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 "$dev5"
 vgcreate $vg $(cat DEVICES)
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 
+lvcreate -l 5 -n $lv1 $vg
+lvcreate -s -l 5 -n $lv2 $vg/$lv1
+
 if aux have_readline; then
 # test *scan and *display tools
 cat <<EOF | lvm
 pvscan --uuid
-vgscan
+vgscan --mknodes
 lvscan
 lvmdiskscan
 vgdisplay --units k $vg
@@ -39,8 +42,11 @@ lvdisplay --units g $vg
 pvdisplay -c "$dev1"
 pvdisplay -s "$dev1"
 vgdisplay -c $vg
+vgdisplay -C $vg
 vgdisplay -s $vg
 lvdisplay -c $vg
+lvdisplay -C $vg
+lvdisplay -m $vg
 EOF
 
 for i in h b s k m g t p e H B S K M G T P E; do
@@ -48,7 +54,7 @@ for i in h b s k m g t p e H B S K M G T P E; do
 done | lvm
 else
 pvscan --uuid
-vgscan
+vgscan --mknodes
 lvscan
 lvmdiskscan
 vgdisplay --units k $vg
@@ -56,18 +62,36 @@ lvdisplay --units g $vg
 pvdisplay -c "$dev1"
 pvdisplay -s "$dev1"
 vgdisplay -c $vg
+vgdisplay -C $vg
 vgdisplay -s $vg
 lvdisplay -c $vg
+lvdisplay -C $vg
+lvdisplay -m $vg
 
 for i in h b s k m g t p e H B S K M G T P E; do
 	pvdisplay --units $i "$dev1"
 done
 fi
 
+not lvdisplay -C -m $vg
+not lvdisplay -c -v $vg
+not lvdisplay --aligned $vg
+not lvdisplay --noheadings $vg
+not lvdisplay --options lv_name $vg
+not lvdisplay --separator : $vg
+not lvdisplay --sort size $vg
+not lvdisplay --unbuffered $vg
+
+not vgdisplay -C -A
+not vgdisplay -C -c
+not vgdisplay -C -s
+not vgdisplay -c -s
+not vgdisplay -A $vg1
+
 # "-persistent y --major 254 --minor 20"
 # "-persistent n"
 # test various lvm utils
-for i in dumpconfig formats segtypes; do
+for i in dumpconfig devtypes formats segtypes tags; do
 	lvm $i
 done
 
@@ -88,8 +112,12 @@ pvcreate -u $TEST_UUID --restorefile  backup.$$ "$dev5"
 vgremove -f $vg
 
 # test pvresize functionality
+# missing params
 not pvresize
+# negative size
 not pvresize --setphysicalvolumesize -10M "$dev1"
+# not existing device
+not pvresize --setphysicalvolumesize 10M "$dev7"
 pvresize --setphysicalvolumesize 10M "$dev1"
 pvresize "$dev1"
 
@@ -98,6 +126,8 @@ not lvmchange
 not lvrename $vg
 not lvrename $vg-xxx
 not lvrename $vg  $vg/$lv-rename $vg/$lv
+not lvscan $vg
+not vgscan $vg
 
 #test vgdisplay -A to select only active VGs
 # all LVs active - VG considered active


