From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Oct 2010 15:00:07 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101008150007.2680.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-08 15:00:07

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Fix usage of --yes flag for ReiserFS resize
	
	Put 'dry' before resize command - using dry for echo had no use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1752&r2=1.1753
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2010/10/08 14:55:19	1.1752
+++ LVM2/WHATS_NEW	2010/10/08 15:00:06	1.1753
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix usage of --yes flag for ReiserFS resize in fsadm.
   Fix detection of mounted filesystems for fsadm when udev is used.
   Fix assignment of default value to LVM variable is fsadm.
   Fix support for --yes flag for fsadm.
--- LVM2/scripts/fsadm.sh	2010/10/08 14:55:20	1.18
+++ LVM2/scripts/fsadm.sh	2010/10/08 15:00:07	1.19
@@ -300,7 +300,7 @@
 	decode_size $1 $BLOCKSIZE
 	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE bytes, bs: $NEWBLOCKCOUNT)"
 	if [ -n "$YES" ]; then
-		dry echo y | $RESIZE_REISER -s $NEWSIZE "$VOLUME"
+		echo y | dry $RESIZE_REISER -s $NEWSIZE "$VOLUME"
 	else
 		dry $RESIZE_REISER -s $NEWSIZE "$VOLUME"
 	fi


