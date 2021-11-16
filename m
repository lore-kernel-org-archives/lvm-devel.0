From: David Teigland <teigland@sourceware.org>
Date: Tue, 16 Nov 2021 20:34:24 +0000 (GMT)
Subject: main - Revert "tests devicesfile-devname: remove searched_devnames"
Message-ID: <20211116203424.C3080385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4b8726b6d4ba9fc4b1f6e79339b1fecb2d890b0
Commit:        e4b8726b6d4ba9fc4b1f6e79339b1fecb2d890b0
Parent:        5c71aa751048f99f4b599a01e7376d8ba951f793
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 16 14:30:09 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 16 14:30:09 2021 -0600

Revert "tests devicesfile-devname: remove searched_devnames"

This reverts commit 8e61c0ad6ecad5e0bcee09e44029e39396c1b59a.

The changes from "device_id: searched_devnames improvements"
allow this to work without the external removal.
---
 test/shell/devicesfile-devname.sh | 23 -----------------------
 1 file changed, 23 deletions(-)

diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index 1b881c1cb..a99fe3e9a 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -100,7 +100,6 @@ lvcreate -l4 -an -i2 -n $lv1 $vg1
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info 
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -117,7 +116,6 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvcreate uses correct dev
 lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
@@ -137,7 +135,6 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 not grep "$PVID3" "$DF"
@@ -150,7 +147,6 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -167,7 +163,6 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvcreate uses correct dev
 lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
@@ -187,7 +182,6 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -202,7 +196,6 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -221,7 +214,6 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvcreate uses correct dev
 lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
@@ -243,7 +235,6 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -264,7 +255,6 @@ cat "$DF"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -281,7 +271,6 @@ cat "$DF"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 not grep "$PVID3" "$DF"
@@ -294,7 +283,6 @@ cat "$DF"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -311,7 +299,6 @@ cat "$DF"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -326,7 +313,6 @@ sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -345,7 +331,6 @@ sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -367,7 +352,6 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -386,7 +370,6 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 not grep "$PVID3" "$DF"
@@ -401,7 +384,6 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > "$DF"
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -421,7 +403,6 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > "$DF"
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -441,7 +422,6 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -465,7 +445,6 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -489,7 +468,6 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
 cat "$DF"
-rm /run/lvm/searched_devnames || true
 _clear_online_files
 pvscan --cache -aay "$dev1"
 pvscan --cache -aay "$dev2"
@@ -530,7 +508,6 @@ sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
 cat "$DF"
 
 _clear_online_files
-rm /run/lvm/searched_devnames || true
 
 # pvscan creates the correct online files and activates correct vg
 pvscan --cache -aay "$dev1"


