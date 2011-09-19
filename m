From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 14:52:34 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20110919145234.15298.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 14:52:33

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Add support for non /dev devices
	
	Since test suite is not using /dev - add support for such dirs into fsadm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2120&r2=1.2121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2011/09/19 13:51:09	1.2120
+++ LVM2/WHATS_NEW	2011/09/19 14:52:33	1.2121
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add support for non /dev device paths into fsadm script.
   Support different PATH setting for fsadm script testing.
   Surround all executed commands with quotes in fsadm script.
   Fix missing '$' in test for content of "$LVM" in fsadm script.
--- LVM2/scripts/fsadm.sh	2011/09/19 13:51:10	1.27
+++ LVM2/scripts/fsadm.sh	2011/09/19 14:52:33	1.28
@@ -177,7 +177,7 @@
 detect_fs() {
 	VOLUME_ORIG=$1
 	VOLUME=${1#/dev/}
-	VOLUME=$("$READLINK" $READLINK_E "/dev/$VOLUME") || error "Cannot get readlink $1"
+	VOLUME=$("$READLINK" $READLINK_E "/dev/$VOLUME") || VOLUME=$("$READLINK" $READLINK_E "$VOLUME_ORIG") || error "Cannot get readlink \"$1\""
 	RVOLUME=$VOLUME
 	case "$RVOLUME" in
 	  /dev/dm-[0-9]*)


