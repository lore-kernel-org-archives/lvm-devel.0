From: David Teigland <teigland@sourceware.org>
Date: Tue, 16 Nov 2021 15:34:24 +0000 (GMT)
Subject: main - tests devicesfile-devname: remove searched_devnames
Message-ID: <20211116153424.61D2C385783B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e61c0ad6ecad5e0bcee09e44029e39396c1b59a
Commit:        8e61c0ad6ecad5e0bcee09e44029e39396c1b59a
Parent:        89c54db16cfca284d78dd3be5316dc9bca67e8ef
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 15 18:04:10 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 15 18:04:10 2021 -0600

tests devicesfile-devname: remove searched_devnames

remove /run/lvm/searched_devnames when preparing each test
in case it has appeared on the system
---
 test/shell/devicesfile-devname.sh | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index f95be52b1..46f66a073 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -100,6 +100,7 @@ lvcreate -l4 -an -i2 -n $lv1 $vg1
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info 
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -116,6 +117,7 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvcreate uses correct dev
 lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
@@ -135,6 +137,7 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 not grep "$PVID3" "$DF"
@@ -147,6 +150,7 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -163,6 +167,7 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvcreate uses correct dev
 lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
@@ -182,6 +187,7 @@ cat "$DF"
 
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -196,6 +202,7 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -214,6 +221,7 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvcreate uses correct dev
 lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
@@ -235,6 +243,7 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -255,6 +264,7 @@ cat "$DF"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -271,6 +281,7 @@ cat "$DF"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 not grep "$PVID3" "$DF"
@@ -283,6 +294,7 @@ cat "$DF"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -299,6 +311,7 @@ cat "$DF"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" "$ORIG" > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -313,6 +326,7 @@ sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -331,6 +345,7 @@ sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -352,6 +367,7 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -370,6 +386,7 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 not grep "$PVID3" "$DF"
@@ -384,6 +401,7 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > "$DF"
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -403,6 +421,7 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > "$DF"
 sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -422,6 +441,7 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
@@ -445,6 +465,7 @@ sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
 sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 # lvmdevices fixes the DF
 lvmdevices --update
 grep "$PVID1" "$DF" |tee out
@@ -468,6 +489,7 @@ cat "$DF"
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
 cat "$DF"
+rm /run/lvm/searched_devnames || true
 _clear_online_files
 pvscan --cache -aay "$dev1"
 pvscan --cache -aay "$dev2"
@@ -508,6 +530,7 @@ sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
 cat "$DF"
 
 _clear_online_files
+rm /run/lvm/searched_devnames || true
 
 # pvscan creates the correct online files and activates correct vg
 pvscan --cache -aay "$dev1"


