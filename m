From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 12:17:10 -0000
Subject: LVM2/test lvm-utils.sh
Message-ID: <20100325121710.31623.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 12:17:10

Modified files:
	test           : lvm-utils.sh 

Log message:
	more diagnostics

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/test/lvm-utils.sh	2010/03/25 11:57:16	1.21
+++ LVM2/test/lvm-utils.sh	2010/03/25 12:17:10	1.22
@@ -161,7 +161,7 @@
 	local num_lvs=$3
 	local num_snaps=$4
 
-	lvs -a -odevices $local_vg
+	lvs -a -o+devices $local_vg
 
 	check_vg_field_ $local_vg pv_count $num_pvs &&
 	check_vg_field_ $local_vg lv_count $num_lvs &&


