From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 11:42:19 -0000
Subject: LVM2/test t-mirror-vgreduce-removemissing.sh
Message-ID: <20100325114219.1020.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 11:42:17

Modified files:
	test           : t-mirror-vgreduce-removemissing.sh 

Log message:
	add debug output and attempt to control which device gets log as intended perhaps

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/11/10 12:32:00	1.5
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2010/03/25 11:42:17	1.6
@@ -25,6 +25,7 @@
 	rm -f out1 out2
 	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
 
+	lvs -a -odevices --noheadings $lv
 	lvs -a -odevices --noheadings $lv | \
 	sed 's/([^)]*)//g; s/[ ,]/\n/g' | sort | uniq > out2
 
@@ -47,6 +48,7 @@
 		sed 's/\[//g; s/\]//g')
 	for i in $mimages; do
 		echo "Checking $vg/$i"
+		lvs -a -odevices --noheadings $vg/$i
 		lvs -a -odevices --noheadings $vg/$i | \
 			sed 's/([^)]*)//g; s/ //g; s/,/ /g' | sort | uniq >> out2
 	done
@@ -128,7 +130,7 @@
 
 #COMM "basic: fail the 2nd mirror image of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvchange -an $vg/$lv1
 aux mimages_are_on_ $lv1 $dev1 $dev2
 mirrorlog_is_on_ $lv1 $dev3


