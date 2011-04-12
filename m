From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Apr 2011 12:39:25 -0000
Subject: LVM2/test t-lvconvert-repair-policy.sh lib/che ...
Message-ID: <20110412123925.23986.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-04-12 12:39:25

Modified files:
	test           : t-lvconvert-repair-policy.sh 
	test/lib       : check.sh 

Log message:
	Make the mirror log checks in t-lvconvert-repair-policy a bit more strict
	(i.e. accurate).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/check.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-lvconvert-repair-policy.sh	2011/02/28 19:44:21	1.9
+++ LVM2/test/t-lvconvert-repair-policy.sh	2011/04/12 12:39:24	1.10
@@ -45,7 +45,7 @@
 aux disable_dev $dev1
 repair 'activation { mirror_image_fault_policy = "replace" mirror_log_fault_policy = "remove" }'
 check mirror $vg mirror
-lvs | grep mirror_mlog
+check active $vg mirror_mlog
 cleanup $dev1
 
 # Fail a leg of a mirror.
@@ -53,7 +53,7 @@
 aux disable_dev $dev1
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
-lvs | grep mirror_mlog
+check active $vg mirror_mlog
 cleanup $dev1
 
 # Fail a leg of a mirror (use old name for policy specification)
@@ -61,7 +61,7 @@
 aux disable_dev $dev1
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
-lvs | grep mirror_mlog
+check active $vg mirror_mlog
 cleanup $dev1
 
 # Fail a leg of a mirror w/ no available spare
@@ -70,7 +70,7 @@
 aux disable_dev $dev2 $dev4
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
-lvs | not grep mirror_mlog
+not check lv_exists $vg mirror_mlog
 cleanup $dev2 $dev4
 
 # Fail the log device of a mirror w/ no available spare
@@ -78,7 +78,7 @@
 aux disable_dev $dev3 $dev4
 repair 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
 check mirror $vg mirror
-lvs | not grep mirror_mlog
+not check lv_exists $vg mirror_mlog
 cleanup $dev3 $dev4
 
 # Fail the log device with a remove policy
@@ -87,5 +87,5 @@
 aux disable_dev $dev3 $dev4
 repair 'activation { mirror_log_fault_policy = "remove" }'
 check mirror $vg mirror core
-lvs | not grep mirror_mlog
+not check lv_exists $vg mirror_mlog
 cleanup $dev3 $dev4
--- LVM2/test/lib/check.sh	2011/01/28 16:08:39	1.4
+++ LVM2/test/lib/check.sh	2011/04/12 12:39:24	1.5
@@ -209,6 +209,14 @@
 	}
 }
 
+lv_exists() {
+	lv="$1/$2"
+	lvl "$lv" >& /dev/null || {
+		echo "$lv expected to exist but does not"
+		exit 1
+	}
+}
+
 pv_field()
 {
     actual=$(trim $(pvs --noheadings $4 -o $2 $1))


