From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Mar 2011 15:46:06 -0000
Subject: LVM2/test t-mirror-vgreduce-removemissing.sh
Message-ID: <20110303154606.2587.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-03 15:46:05

Modified files:
	test           : t-mirror-vgreduce-removemissing.sh 

Log message:
	Avoid using pipes on lv commands
	
	Failure on pipe kills lv command and produces memory stacktrace.
	Add 'true' for empty grep/sed to avoid generating stacktrace.
	
	This should help with long time (7min) for this test on Lenny testing maching
	(mimage was filler with stacktrace and each word was used as LV name).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2011/01/05 00:16:20	1.10
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2011/03/03 15:46:05	1.11
@@ -24,8 +24,8 @@
 	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
 
 	lvs -a -o+devices $lv
-	lvs -a -odevices --noheadings $lv | \
-	sed 's/([^)]*)//g; s/[ ,]/\n/g' | sort | uniq > out2
+	lvs -a -odevices --noheadings $lv > lvs_log
+	sed 's/([^)]*)//g; s/[ ,]/\n/g' lvs_log | sort | uniq > out2 || true
 
 	diff --ignore-blank-lines out1 out2
 }
@@ -41,14 +41,15 @@
 	echo "Check if mirror images of $lv are on PVs $pvs"
 	rm -f out1 out2
 	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
-
-	mimages=$(lvs --noheadings -a -o lv_name $vg | grep "${lv}_mimage_" | \
-		sed 's/\[//g; s/\]//g')
+	lvs --noheadings -a -o lv_name $vg > lvs_log
+	mimages=$(grep "${lv}_mimage_" lvs_log | \
+		sed 's/\[//g; s/\]//g' || true)
+	
 	for i in $mimages; do
 		echo "Checking $vg/$i"
 		lvs -a -o+devices $vg/$i
-		lvs -a -odevices --noheadings $vg/$i | \
-			sed 's/([^)]*)//g; s/ //g; s/,/ /g' | sort | uniq >> out2
+		lvs -a -odevices --noheadings $vg/$i > lvs_log
+		sed 's/([^)]*)//g; s/ //g; s/,/ /g' lvs_log | sort | uniq >> out2 || true
 	done
 
 	diff --ignore-blank-lines out1 out2


