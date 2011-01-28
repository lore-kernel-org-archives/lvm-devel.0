From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:07:05 -0000
Subject: LVM2/test t-lvconvert-mirror-basic.sh
Message-ID: <20110128160705.29046.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:07:05

Modified files:
	test           : t-lvconvert-mirror-basic.sh 

Log message:
	Accelerate mirror tests
	
	Instead of recreation of whole device set for each test round,
	just cleanup created LVs to empty VG.
	Lower the size of PV devices to 16MB

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-lvconvert-mirror-basic.sh	2011/01/11 17:05:09	1.6
+++ LVM2/test/t-lvconvert-mirror-basic.sh	2011/01/28 16:07:04	1.7
@@ -77,8 +77,6 @@
 		max_log_count=$start_log_count
 	fi
 
-	aux prepare_vg 5
-
 	if [ $start_count -gt 0 ]; then
 		# Are there extra devices for the log or do we overlap
 		if [ $(($start_count_p1 + $start_log_count)) -gt ${#dev_array[@]} ]; then
@@ -123,7 +121,7 @@
 	fi
 }
 
-aux prepare_vg 5
+aux prepare_vg 5 16
 
 test_many() {
 	i=$1
@@ -135,7 +133,9 @@
 				: "Testing mirror conversion -m$i/$k -> -m$j/$l"
 				: ----------------------------------------------------
 				test_lvconvert $i $k $j $l 0
+				lvremove -ff $vg
 				test_lvconvert $i $k $j $l 1
+				lvremove -ff $vg
 			done
 		done
 	done


