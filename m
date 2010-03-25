From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 12:16:18 -0000
Subject: LVM2/test t-mirror-vgreduce-removemissing.sh
Message-ID: <20100325121618.31293.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 12:16:17

Modified files:
	test           : t-mirror-vgreduce-removemissing.sh 

Log message:
	more diagnostics

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2010/03/25 11:42:17	1.6
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2010/03/25 12:16:17	1.7
@@ -25,7 +25,7 @@
 	rm -f out1 out2
 	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
 
-	lvs -a -odevices --noheadings $lv
+	lvs -a -o+devices $lv
 	lvs -a -odevices --noheadings $lv | \
 	sed 's/([^)]*)//g; s/[ ,]/\n/g' | sort | uniq > out2
 
@@ -48,7 +48,7 @@
 		sed 's/\[//g; s/\]//g')
 	for i in $mimages; do
 		echo "Checking $vg/$i"
-		lvs -a -odevices --noheadings $vg/$i
+		lvs -a -o+devices $vg/$i
 		lvs -a -odevices --noheadings $vg/$i | \
 			sed 's/([^)]*)//g; s/ //g; s/,/ /g' | sort | uniq >> out2
 	done


