From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Dec 2009 15:38:31 -0000
Subject: LVM2 lib/metadata/mirror.c test/t-lvconvert-re ...
Message-ID: <20091217153831.25837.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-12-17 15:38:30

Modified files:
	lib/metadata   : mirror.c 
	test           : t-lvconvert-repair.sh 

Log message:
	Fix removal of multiple devices from a mirror (+ regression test).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/metadata/mirror.c	2009/12/09 19:53:39	1.99
+++ LVM2/lib/metadata/mirror.c	2009/12/17 15:38:29	1.100
@@ -533,6 +533,7 @@
 			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
 				if (!shift_mirror_images(mirrored_seg, s))
 					return_0;
+				s--; /* adjust counter after shifting */
 				new_area_count--;
 			}
 		}
@@ -783,7 +784,7 @@
 					 DEFAULT_MIRROR_LOG_FAULT_POLICY);
 	else
 		policy = find_config_str(NULL, "activation/mirror_device_fault_policy",
-					 DEFAULT_MIRROR_DEV_FAULT_POLICY);
+					 DEFAULT_MIRROR_IMAGE_FAULT_POLICY);
 
 	if (!strcmp(policy, "remove"))
 		return MIRROR_REMOVE;
--- LVM2/test/t-lvconvert-repair.sh	2009/06/04 12:01:16	1.2
+++ LVM2/test/t-lvconvert-repair.sh	2009/12/17 15:38:29	1.3
@@ -11,9 +11,36 @@
 
 . ./test-utils.sh
 
-prepare_vg 4
+prepare_vg 5
+
+# fail multiple devices
+
+lvcreate -m 3 -L 1 -n 3way $vg
+disable_dev $dev2 $dev4
+echo n | lvconvert -i 1 --repair $vg/3way
+lvs -a -o +devices > lvlist
+not grep unknown lvlist
+vgreduce --removemissing $vg
+enable_dev $dev2 $dev4
+lvchange -a n $vg/3way
+
+vgremove -ff $vg
+vgcreate $vg $dev1 $dev2 $dev3 $dev4
+
+lvcreate -m 2 -L 1 -n 4way $vg
+disable_dev $dev1 $dev2
+echo n | lvconvert -i 1 --repair $vg/4way
+lvs -a -o +devices > lvlist
+not grep unknown lvlist
+vgreduce --removemissing $vg
+enable_dev $dev1 $dev2
+lvchange -a n $vg/4way
+
+# fail single devices
+
+vgremove -ff $vg
+vgcreate $vg $dev1 $dev2 $dev3
 
-vgreduce $vg $dev4
 lvcreate -m 1 -L 1 -n mirror $vg
 
 lvchange -a n $vg/mirror


