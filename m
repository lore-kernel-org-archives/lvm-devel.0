From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Oct 2010 15:02:07 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101008150207.5222.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-08 15:02:06

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Add support for noninterctive shell execution
	
	Try to distinguish between the case of  using interactive shell and non
	interactive running - different combinations of  '-y' and '-p' option
	needs to be used for fsck.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1753&r2=1.1754
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2010/10/08 15:00:06	1.1753
+++ LVM2/WHATS_NEW	2010/10/08 15:02:05	1.1754
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Better support of noninteractive shell execution of fsadm.
   Fix usage of --yes flag for ReiserFS resize in fsadm.
   Fix detection of mounted filesystems for fsadm when udev is used.
   Fix assignment of default value to LVM variable is fsadm.
--- LVM2/scripts/fsadm.sh	2010/10/08 15:00:07	1.19
+++ LVM2/scripts/fsadm.sh	2010/10/08 15:02:05	1.20
@@ -368,7 +368,11 @@
 	detect_mounted && error "Cannot fsck device \"$VOLUME\", filesystem is mounted on $MOUNTED"
 	case "$FSTYPE" in
 	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
-	  *) dry $FSCK $YES "$VOLUME" ;;
+	  *)    # check if executed from interactive shell environment
+		case "$-" in
+		  *i*) dry $FSCK $YES $FORCE "$VOLUME" ;;
+		  *) dry $FSCK $FORCE -p "$VOLUME" ;;
+		esac
 	esac
 }
 


