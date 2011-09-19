From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 13:43:51 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20110919134351.27212.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 13:43:50

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Fix missing '$' in test

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2117&r2=1.2118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2011/09/19 12:48:02	1.2117
+++ LVM2/WHATS_NEW	2011/09/19 13:43:50	1.2118
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix missing '$' in test for content of "$LVM" in fsadm script.
   Move debug message in exec_cmd after sync_local_dev_names.
   Fix clvmd processing of invalid request on local socket.
   Fix command line option decoding.
--- LVM2/scripts/fsadm.sh	2010/11/11 12:17:15	1.24
+++ LVM2/scripts/fsadm.sh	2011/09/19 13:43:50	1.25
@@ -446,7 +446,7 @@
 test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
   -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
   -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
-  -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVM" \
+  -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "$LVM" \
   || error "Required command definitions in the script are missing!"
 
 $LVM version >/dev/null 2>&1 || error "Could not run lvm binary '$LVM'"


