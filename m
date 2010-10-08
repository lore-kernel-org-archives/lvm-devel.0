From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Oct 2010 13:49:21 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101008134921.2906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-08 13:49:20

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Support for passing --yes flag recursively.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1749&r2=1.1750
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2010/10/08 13:47:10	1.1749
+++ LVM2/WHATS_NEW	2010/10/08 13:49:20	1.1750
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix support for --yes flag for fsadm.
   Do not execute lvresize with --dry-run option for fsadm.
   Fix fsadm return error code from user's break action.
   Allow CC to be overridden at build time (for 'scan-build make').
--- LVM2/scripts/fsadm.sh	2010/10/08 13:47:10	1.15
+++ LVM2/scripts/fsadm.sh	2010/10/08 13:49:20	1.16
@@ -51,7 +51,7 @@
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY-lvm}
 
-YES=
+YES=${_FSADM_YES}
 DRY=0
 VERB=
 FORCE=
@@ -128,6 +128,8 @@
 	if [ "$DO_LVRESIZE" -eq 2 ]; then
 		# start LVRESIZE with the filesystem modification flag
 		# and allow recursive call of fsadm
+		_FSADM_YES=$YES
+		export _FSADM_YES
 		unset FSADM_RUNNING
 		dry exec $LVM lvresize $VERB $FORCE -r -L${NEWSIZE}b $VOLUME_ORIG
 	fi


