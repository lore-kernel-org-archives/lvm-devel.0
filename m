From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 19 Jan 2011 19:22:07 -0000
Subject: LVM2/test t-lvconvert-repair-policy.sh
Message-ID: <20110119192207.5486.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-19 19:22:07

Modified files:
	test           : t-lvconvert-repair-policy.sh 

Log message:
	Add test to make sure that a log device is retained when a
	mirror image fails and the policies are set to:
	mirror_image_fault_policy = "replace"
	mirror_log_fault_policy = "remove"

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-lvconvert-repair-policy.sh	2011/01/11 17:05:09	1.7
+++ LVM2/test/t-lvconvert-repair-policy.sh	2011/01/19 19:22:07	1.8
@@ -39,6 +39,14 @@
 cleanup $dev1
 
 # Fail a leg of a mirror.
+# Expected result: Mirror (leg replaced, should retain log)
+aux disable_dev $dev1
+repair 'activation { mirror_image_fault_policy = "replace" mirror_log_fault_policy = "remove" }'
+check mirror $vg mirror
+lvs | grep mirror_mlog
+cleanup $dev1
+
+# Fail a leg of a mirror.
 # Expected result: Mirror (leg replaced)
 aux disable_dev $dev1
 repair 'activation { mirror_image_fault_policy = "replace" }'
@@ -49,7 +57,7 @@
 # Fail a leg of a mirror (use old name for policy specification)
 # Expected result: Mirror (leg replaced)
 aux disable_dev $dev1
-repair 'activation { mirror_device_fault_policy = "replace" }'
+repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 lvs | grep mirror_mlog
 cleanup $dev1


