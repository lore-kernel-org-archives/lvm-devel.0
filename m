From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 23:58:42 -0000
Subject: LVM2/test shell/lvcreate-repair.sh shell/pool- ...
Message-ID: <20120223235842.29824.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 23:58:42

Modified files:
	test/shell     : lvcreate-repair.sh pool-labels.sh 
	                 vgimportclone.sh 
	test/lib       : aux.sh 

Log message:
	Make the calls to pvscan --lvmetad in the testsuite slightly more civilised.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-repair.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pool-labels.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgimportclone.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/test/shell/lvcreate-repair.sh	2012/02/23 14:55:29	1.3
+++ LVM2/test/shell/lvcreate-repair.sh	2012/02/23 23:58:42	1.4
@@ -86,7 +86,7 @@
 
 # dirty game
 dd if=/dev/zero of="$dev3" bs=256K count=1
-pvscan --lvmetad $dev3 || true # udev be watching you
+aux notify_lvmetad $dev3 # udev be watching you
 
 vgreduce --removemissing --force $vg
 
--- LVM2/test/shell/pool-labels.sh	2012/02/23 13:11:10	1.2
+++ LVM2/test/shell/pool-labels.sh	2012/02/23 23:58:42	1.3
@@ -18,7 +18,7 @@
   # printf comes from coreutils, and is probably not posix either
   env printf "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of=$2 bs=5 seek=1 conv=notrunc
   env printf "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
-  pvscan --lvmetad "$2" || true
+  aux notify_lvmetad "$2"
 }
 
 env printf "" || exit 200 # skip if printf is not available
--- LVM2/test/shell/vgimportclone.sh	2012/02/23 13:11:10	1.2
+++ LVM2/test/shell/vgimportclone.sh	2012/02/23 23:58:42	1.3
@@ -17,7 +17,7 @@
 
 # Clone the LUN
 dd if=$dev1 of=$dev2 bs=256K count=1
-pvscan --lvmetad $dev2 || true
+aux notify_lvmetad $dev2
 
 # Verify pvs works on each device to give us vgname
 check pv_field $dev1 vg_name $vg1
@@ -30,8 +30,8 @@
 # concerned, can only live on a single device. With the last pvscan, we told it
 # that PV from $dev1 now lives on $dev2, but in fact this is not true anymore,
 # since we wrote a different PV over $dev2.
-pvscan --lvmetad $dev2 || true
-pvscan --lvmetad $dev1 || true
+aux notify_lvmetad $dev2
+aux notify_lvmetad $dev1
 
 # Verify we can activate / deactivate the LV from both VGs
 lvchange -ay $vg1/$lv1 $vg2/$lv1
--- LVM2/test/lib/aux.sh	2012/02/23 13:11:10	1.38
+++ LVM2/test/lib/aux.sh	2012/02/23 23:58:42	1.39
@@ -78,6 +78,12 @@
 	sleep 1
 }
 
+notify_lvmetad() {
+	if test -e LOCAL_LVMETAD; then
+		pvscan --lvmetad "$@" || true
+	fi
+}
+
 teardown_devs() {
 	# Delete any remaining dm/udev semaphores
 	teardown_udev_cookies
@@ -328,7 +334,7 @@
 	    min=$(($(stat --printf=0x%T $dev)))
 	    echo "disabling device $dev ($maj:$min)"
             dmsetup remove -f $dev || true
-	    pvscan --lvmetad $maj:$min || true
+	    notify_lvmetad $maj:$min
 	done
 	finish_udev_transaction
 
@@ -342,7 +348,7 @@
 		dmsetup create -u TEST-$name $name $name.table || dmsetup load $name $name.table
 		# using device name (since device path does not exists yes with udev)
 		dmsetup resume $name
-		pvscan --lvmetad $dev || true
+		notify_lvmetad $dev
 	done
 	finish_udev_transaction
 }


