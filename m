From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Oct 2010 13:47:12 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101008134712.1803.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-08 13:47:11

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Correctly respect --dry-run option for fsadm
	
	Fix missing 'dry' execution of lvresize - fixing problem where resize
	command were 'dry-run' executed - but lvresize has been executed for real.
	
	Also adapt code slightly to support better recursive execution of fsadm
	through lvresize call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1748&r2=1.1749
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2010/10/08 12:35:56	1.1748
+++ LVM2/WHATS_NEW	2010/10/08 13:47:10	1.1749
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Do not execute lvresize with --dry-run option for fsadm.
   Fix fsadm return error code from user's break action.
   Allow CC to be overridden at build time (for 'scan-build make').
   Rename 'flags' to 'status' in struct metadata_area.
--- LVM2/scripts/fsadm.sh	2010/10/08 12:35:59	1.14
+++ LVM2/scripts/fsadm.sh	2010/10/08 13:47:10	1.15
@@ -125,10 +125,13 @@
 	IFS=$IFS_OLD
 	trap 2
 
-	# start LVRESIZE with the filesystem modification flag
-	# and allow recursive call of fsadm
-	unset FSADM_RUNNING
-	test "$DO_LVRESIZE" -eq 2 && exec $LVM lvresize $VERB -r -L$(( $NEWSIZE / 1048576 )) $VOLUME
+	if [ "$DO_LVRESIZE" -eq 2 ]; then
+		# start LVRESIZE with the filesystem modification flag
+		# and allow recursive call of fsadm
+		unset FSADM_RUNNING
+		dry exec $LVM lvresize $VERB $FORCE -r -L${NEWSIZE}b $VOLUME_ORIG
+	fi
+        
 	# error exit status for break
 	exit ${1:-1}
 }


