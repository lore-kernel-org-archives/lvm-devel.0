From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Aug 2008 10:40:45 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh
Message-ID: <20080828104045.7200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-28 10:40:44

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 

Log message:
	Fix lvmdump metadata gather option (-m) to work correctly. (Jaroslav Stava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.947&r2=1.948
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2008/08/16 09:46:55	1.947
+++ LVM2/WHATS_NEW	2008/08/28 10:40:44	1.948
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Fix lvmdump metadata gather option (-m) to work correctly.
   Fix allocation bug in text metadata format write error path.
   Fix vgcfgbackup to properly check filename if template is used.
   configure aborts if lcov or genhtml are missing with --enable-profiling
--- LVM2/scripts/lvm_dump.sh	2007/10/03 15:00:51	1.12
+++ LVM2/scripts/lvm_dump.sh	2008/08/28 10:40:44	1.13
@@ -206,7 +206,7 @@
 
 	pvs="$("$LVM" pvs --separator , --noheadings --units s --nosuffix -o \
 	    name,pe_start 2>> "$log" | $SED -e 's/^ *//')"
-	for line in "$pvs"
+	for line in $pvs
 	do
 		test -z "$line" && continue
 		pv="$(echo $line | $CUT -d, -f1)"


