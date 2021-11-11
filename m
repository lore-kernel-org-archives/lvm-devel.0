From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Nov 2021 22:59:21 +0000 (GMT)
Subject: main - tests vgchange-pvs-online: clean up with devices file
Message-ID: <20211111225921.956F3385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b945ea1c93a1f6ac76a082391652193b475950c7
Commit:        b945ea1c93a1f6ac76a082391652193b475950c7
Parent:        20c550ab10e50d25249ed0b0553ff8a33ed3348f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 11 16:38:10 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 11 16:38:10 2021 -0600

tests vgchange-pvs-online: clean up with devices file

changing the dev names resulted in stale devices file
entries that created noise in the output.
---
 test/shell/vgchange-pvs-online.sh | 59 ++++++++++++++++++++++++++++-----------
 1 file changed, 42 insertions(+), 17 deletions(-)

diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
index 1e9c37db8..ced03f4da 100644
--- a/test/shell/vgchange-pvs-online.sh
+++ b/test/shell/vgchange-pvs-online.sh
@@ -19,20 +19,45 @@ _clear_online_files() {
 
 aux prepare_devs 4
 
+DFDIR="$LVM_SYSTEM_DIR/devices"
+mkdir -p "$DFDIR" || true
+DF="$DFDIR/system.devices"
+
 # Because mapping devno to devname gets dm name from sysfs
 aux lvmconf 'devices/scan = "/dev"'
 base1=$(basename $dev1)
 base2=$(basename $dev2)
 base3=$(basename $dev3)
 base4=$(basename $dev4)
+bd1=/dev/mapper/$base1
+bd2=/dev/mapper/$base2
+bd3=/dev/mapper/$base3
+bd4=/dev/mapper/$base4
 aux extend_filter "a|/dev/mapper/$base1|"
 aux extend_filter "a|/dev/mapper/$base2|"
 aux extend_filter "a|/dev/mapper/$base3|"
 aux extend_filter "a|/dev/mapper/$base4|"
 
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3"
-pvcreate "$dev4"
+# Changing names will confuse df based on devname
+if lvmdevices; then
+rm -f "$DF"
+touch "$DF"
+lvmdevices --adddev "$bd1"
+lvmdevices --adddev "$bd2"
+lvmdevices --adddev "$bd3"
+lvmdevices --adddev "$bd4"
+cat "$DF"
+fi
+
+# Using $bd instead of $dev because validation of pvid file content
+# checks that the devname begins with /dev.
+
+# FIXME: test vgchange aay with pvs_online that includes devname in pvid file
+# and the devices file entry uses devname with a stale name.
+
+vgcreate $vg1 "$bd1" "$bd2"
+vgcreate $vg2 "$bd3"
+pvcreate "$bd4"
 
 lvcreate -l1 -n $lv1 -an $vg1
 lvcreate -l1 -n $lv2 -an $vg1
@@ -42,14 +67,14 @@ lvcreate -l1 -n $lv1 -an $vg2
 
 _clear_online_files
 
-pvscan --cache "$dev1"
-pvscan --cache "$dev2"
+pvscan --cache "$bd1"
+pvscan --cache "$bd2"
 vgchange -aay --autoactivation event $vg1
 check lv_field $vg1/$lv1 lv_active "active"
 check lv_field $vg1/$lv2 lv_active "active"
 check lv_field $vg2/$lv1 lv_active ""
 
-pvscan --cache "$dev3"
+pvscan --cache "$bd3"
 vgchange -aay --autoactivation event $vg2
 check lv_field $vg2/$lv1 lv_active "active"
 
@@ -60,13 +85,13 @@ if which strace; then
 vgchange -an
 _clear_online_files
 
-pvscan --cache "$dev1"
-pvscan --cache "$dev2"
+pvscan --cache "$bd1"
+pvscan --cache "$bd2"
 strace -e io_submit vgchange -aay --autoactivation event $vg1 2>&1|tee trace.out
 test "$(grep io_submit trace.out | wc -l)" -eq 3
 rm trace.out
 
-strace -e io_submit pvscan --cache "$dev3" 2>&1|tee trace.out
+strace -e io_submit pvscan --cache "$bd3" 2>&1|tee trace.out
 test "$(grep io_submit trace.out | wc -l)" -eq 1
 rm trace.out
 
@@ -85,19 +110,19 @@ check lv_field $vg1/$lv1 lv_active ""
 check lv_field $vg1/$lv2 lv_active ""
 check lv_field $vg2/$lv1 lv_active ""
 
-pvscan --cache "$dev1"
+pvscan --cache "$bd1"
 vgchange -aay --autoactivation event
 check lv_field $vg1/$lv1 lv_active ""
 check lv_field $vg1/$lv2 lv_active ""
 check lv_field $vg2/$lv1 lv_active ""
 
-pvscan --cache "$dev2"
+pvscan --cache "$bd2"
 vgchange -aay --autoactivation event
 check lv_field $vg1/$lv1 lv_active "active"
 check lv_field $vg1/$lv2 lv_active "active"
 check lv_field $vg2/$lv1 lv_active ""
 
-pvscan --cache "$dev3"
+pvscan --cache "$bd3"
 vgchange -aay --autoactivation event
 check lv_field $vg2/$lv1 lv_active "active"
 
@@ -115,7 +140,7 @@ vgchange -an
 _clear_online_files
 
 # incomplete pvs_online, vgchange falls back to full label scan
-pvscan --cache "$dev1"
+pvscan --cache "$bd1"
 vgchange -aay --autoactivation event $vg1
 check lv_field $vg1/$lv1 lv_active "active"
 check lv_field $vg1/$lv2 lv_active "active"
@@ -126,7 +151,7 @@ _clear_online_files
 # incomplete pvs_online, pvs_online from different vg,
 # no pvs_online found for vg arg so vgchange falls back to full label scan
 
-pvscan --cache "$dev3"
+pvscan --cache "$bd3"
 vgchange -aay --autoactivation event $vg1
 check lv_field $vg1/$lv1 lv_active "active"
 check lv_field $vg1/$lv2 lv_active "active"
@@ -140,14 +165,14 @@ _clear_online_files
 
 # same tests but using command options matching udev rule
 
-pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev1"
-pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev2"
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$bd1"
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$bd2"
 vgchange -aay --autoactivation event $vg1
 check lv_field $vg1/$lv1 lv_active "active"
 check lv_field $vg1/$lv2 lv_active "active"
 check lv_field $vg2/$lv1 lv_active ""
 
-pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev3"
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$bd3"
 vgchange -aay --autoactivation event $vg2
 check lv_field $vg2/$lv1 lv_active "active"
 


