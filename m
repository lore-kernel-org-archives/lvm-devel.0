From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 31 Mar 2010 02:36:03 -0000
Subject: LVM2/test t-lvconvert-repair-policy.sh t-lvcon ...
Message-ID: <20100331023603.5038.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-03-31 02:36:03

Modified files:
	test           : t-lvconvert-repair-policy.sh 
	                 t-lvconvert-repair.sh 

Log message:
	For the mirror repair tests, we should use --ignoremonitoring because
	we are running the repair manually.  If we don't ignore, then dmeventd
	and the manually run repair can collide.  (We should still get clean
	results in such a case, but it makes it harder to validate the test
	results.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/t-lvconvert-repair-policy.sh	2010/03/26 22:15:44	1.2
+++ LVM2/test/t-lvconvert-repair-policy.sh	2010/03/31 02:36:03	1.3
@@ -21,7 +21,7 @@
 	for d in "$@"; do enable_dev $d; done
 	for d in "$@"; do vgextend $vg $d; done
 	lvremove -ff $vg/mirror
-	lvcreate -m 1 -l 2 -n mirror $vg $dev1 $dev2 $dev3:0
+	lvcreate -m 1 --ig -l 2 -n mirror $vg $dev1 $dev2 $dev3:0
 }
 
 repair() {
--- LVM2/test/t-lvconvert-repair.sh	2010/03/26 22:15:44	1.5
+++ LVM2/test/t-lvconvert-repair.sh	2010/03/31 02:36:03	1.6
@@ -15,7 +15,7 @@
 
 # fail multiple devices
 
-lvcreate -m 3 -L 1 -n 3way $vg
+lvcreate -m 3 --ig -L 1 -n 3way $vg
 disable_dev $dev2 $dev4
 echo n | lvconvert -i 1 --repair $vg/3way
 lvs -a -o +devices > lvlist
@@ -27,7 +27,7 @@
 vgremove -ff $vg
 vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
 
-lvcreate -m 2 -L 1 -n 4way $vg
+lvcreate -m 2 --ig -L 1 -n 4way $vg
 disable_dev $dev1 $dev2
 echo n | lvconvert -i 1 --repair $vg/4way
 lvs -a -o +devices > lvlist
@@ -41,7 +41,7 @@
 vgremove -ff $vg
 vgcreate -c n $vg $dev1 $dev2 $dev3
 
-lvcreate -m 1 -L 1 -n mirror $vg
+lvcreate -m 1 --ig -L 1 -n mirror $vg
 
 lvchange -a n $vg/mirror
 vgextend $vg $dev4
@@ -63,11 +63,15 @@
 disable_dev $dev3
 lvconvert -y -i 1 --repair $vg/mirror
 vgreduce --removemissing $vg
-
 enable_dev $dev3
 vgextend $vg $dev3
-lvcreate -m 2 -l 1 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4
+lvremove -ff $vg
+
+# Test repair of inactive mirror with log failure
+#  Replacement should fail, but covert should succeed (switch to corelog)
+lvcreate -m 2 --ig -l 2 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4:0
 vgchange -a n $vg
 pvremove -ff -y $dev4
 echo 'y' | lvconvert -y -i 1 --repair $vg/mirror2
+# FIXME: check that mirror ok and log is now 'core'
 vgs


