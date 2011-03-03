From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Mar 2011 12:30:33 -0000
Subject: LVM2/test t-lvconvert-mirror-basic.sh
Message-ID: <20110303123033.7334.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-03 12:30:33

Modified files:
	test           : t-lvconvert-mirror-basic.sh 

Log message:
	Do not echo y to lvconvert
	
	This lvconvert is now able to complete operation automatically without question.
	So remove  'echo y |'  - it's breaking pipe on some bash versions.
	
	i.e.:
	+ echo y
	./t-lvconvert-mirror-basic.sh: line 104: echo: write error: Broken pipe
	
	while command has completed this operation succesfully

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-lvconvert-mirror-basic.sh	2011/01/28 16:07:04	1.7
+++ LVM2/test/t-lvconvert-mirror-basic.sh	2011/03/03 12:30:33	1.8
@@ -101,7 +101,7 @@
 		alloc="--alloc anywhere"
 	fi
 
-	echo y | lvconvert -m $finish_count --mirrorlog $finish_log_type \
+	lvconvert -m $finish_count --mirrorlog $finish_log_type \
 		$vg/$lv1 $alloc
 
 	if ! $active; then


