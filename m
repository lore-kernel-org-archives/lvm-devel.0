From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2011 19:44:22 -0000
Subject: LVM2/test t-lvconvert-repair-policy.sh t-lvcon ...
Message-ID: <20110228194422.1324.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-28 19:44:21

Modified files:
	test           : t-lvconvert-repair-policy.sh 
	                 t-lvconvert-repair-replace.sh 
	                 t-lvconvert-repair-snapshot.sh 
	                 t-lvconvert-repair.sh t-lvcreate-mirror.sh 
	                 t-lvcreate-pvtags.sh 

Log message:
	Use backward compatible configuration for test
	
	Currently the test are not properly working with new code.
	Use settings for the previous behaviour.
	
	FIXME: update tests to properly test new allocation policies.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-replace.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-snapshot.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-mirror.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-lvconvert-repair-policy.sh	2011/01/19 19:22:07	1.8
+++ LVM2/test/t-lvconvert-repair-policy.sh	2011/02/28 19:44:21	1.9
@@ -12,6 +12,8 @@
 . lib/test
 
 aux prepare_vg 4
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # Clean-up and create a 2-way mirror, where the the
 # leg devices are always on $dev[12] and the log
--- LVM2/test/t-lvconvert-repair-replace.sh	2011/01/11 17:05:09	1.3
+++ LVM2/test/t-lvconvert-repair-replace.sh	2011/02/28 19:44:21	1.4
@@ -12,6 +12,8 @@
 . lib/test
 
 aux prepare_vg 6
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 3-way, disk log
 # multiple failures, full replace
--- LVM2/test/t-lvconvert-repair-snapshot.sh	2011/01/07 14:56:52	1.1
+++ LVM2/test/t-lvconvert-repair-snapshot.sh	2011/02/28 19:44:21	1.2
@@ -11,6 +11,9 @@
 . lib/test
 
 aux prepare_vg 5
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
 lvcreate -m 3 --ig -L 2M -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
 lvcreate -s $vg/4way -L 2M -n snap
 
--- LVM2/test/t-lvconvert-repair.sh	2011/01/11 17:05:09	1.10
+++ LVM2/test/t-lvconvert-repair.sh	2011/02/28 19:44:21	1.11
@@ -11,6 +11,8 @@
 
 . lib/test
 
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # fail multiple devices
 
--- LVM2/test/t-lvcreate-mirror.sh	2011/01/05 00:16:20	1.3
+++ LVM2/test/t-lvcreate-mirror.sh	2011/02/28 19:44:21	1.4
@@ -11,6 +11,8 @@
 
 . lib/test
 aux prepare_vg 5 80
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 2-way mirror with corelog, 2 PVs
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
--- LVM2/test/t-lvcreate-pvtags.sh	2011/01/05 00:16:20	1.8
+++ LVM2/test/t-lvcreate-pvtags.sh	2011/02/28 19:44:21	1.9
@@ -11,6 +11,9 @@
 . lib/test
 
 aux prepare_pvs 3
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
 # not required, just testing
 aux pvcreate --metadatacopies 0 $dev1
 


