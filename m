From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 12:53:07 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20120316125307.21373.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 12:53:06

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Fix string parsing
	
	Fix propagation of -e option - pass it via internal shell variable.
	Fix parsing of /proc/mounts files (don't check for substrings).
	as reported by O.Mangold with suggested patch:
	https://www.redhat.com/archives/linux-lvm/2012-February/msg00030.html
	Properly pass arguments with spaces ("$@")
	Add validation for YES and EXTOFF variable content.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2358&r2=1.2359
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/WHATS_NEW	2012/03/16 10:46:25	1.2358
+++ LVM2/WHATS_NEW	2012/03/16 12:53:05	1.2359
@@ -1,5 +1,8 @@
 Version 2.02.96 - 
 ================================
+  Fix fsadm propagation of -e option.
+  Fix fsadm parsing of /proc/mounts files (don't check for substrings).
+  Fix fsadm usage of arguments with space.
   Fix a regression in handling of lvchange/lvcreate --major/--minor.
   Fix name conflicts that prevent down-converting RAID1 when specifying a device
   Improve thin_check option passing and use configured path.
--- LVM2/scripts/fsadm.sh	2011/09/19 19:36:53	1.29
+++ LVM2/scripts/fsadm.sh	2012/03/16 12:53:06	1.30
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -62,7 +62,7 @@
 DRY=0
 VERB=
 FORCE=
-EXTOFF=0
+EXTOFF=${_FSADM_EXTOFF:-0}
 DO_LVRESIZE=0
 FSTYPE=unknown
 VOLUME=unknown
@@ -121,7 +121,7 @@
 		return 0
 	fi
 	verbose "Executing $@"
-	$@
+	"$@"
 }
 
 cleanup() {
@@ -141,7 +141,8 @@
 		# start LVRESIZE with the filesystem modification flag
 		# and allow recursive call of fsadm
 		_FSADM_YES=$YES
-		export _FSADM_YES
+		_FSADM_EXTOFF=$EXTOFF
+		export _FSADM_YES _FSADM_EXTOFF
 		unset FSADM_RUNNING
 		test -n "$LVM_BINARY" && PATH=$_SAVEPATH
 		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b "$VOLUME_ORIG"
@@ -200,10 +201,10 @@
 detect_mounted()  {
 	test -e "$PROCMOUNTS" || error "Cannot detect mounted device \"$VOLUME\""
 
-	MOUNTED=$("$GREP" ^"$VOLUME" "$PROCMOUNTS")
+	MOUNTED=$("$GREP" "^$VOLUME[ \t]" "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
-	test -z "$MOUNTED" && MOUNTED=$("$GREP" ^"$RVOLUME" "$PROCMOUNTS")
+	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \t]" "$PROCMOUNTS")
 
 	# cut device name prefix and trim everything past mountpoint
 	# echo translates \040 to spaces
@@ -212,8 +213,8 @@
 
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
-		MOUNTED=$(LANG=C "$MOUNT" | "$GREP" ^"$VOLUME")
-		test -z "$MOUNTED" && MOUNTED=$(LANG=C "$MOUNT" | "$GREP" ^"$RVOLUME")
+		MOUNTED=$(LANG=C "$MOUNT" | "$GREP" "^$VOLUME[ \t]")
+		test -z "$MOUNTED" && MOUNTED=$(LANG=C "$MOUNT" | "$GREP" "^$RVOLUME[ \t]")
 		MOUNTED=${MOUNTED##* on }
 		MOUNTED=${MOUNTED% type *} # allow type in the mount name
 	fi
@@ -484,6 +485,9 @@
 	shift
 done
 
+test "$YES" = "-y" || YES=
+test "$EXTOFF" -eq 1 || EXTOFF=0
+
 if [ -n "$CHECK" ]; then
 	check "$CHECK"
 elif [ -n "$RESIZE" ]; then


