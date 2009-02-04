From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Feb 2009 12:47:06 -0000
Subject: LVM2 ./WHATS_NEW man/fsadm.8.in scripts/fsadm.sh
Message-ID: <20090204124706.3630.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-02-04 12:47:05

Modified files:
	.              : WHATS_NEW 
	man            : fsadm.8.in 
	scripts        : fsadm.sh 

Log message:
	add support for ext4 resize in fsadm

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1034&r2=1.1035
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/fsadm.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2009/02/03 16:23:19	1.1034
+++ LVM2/WHATS_NEW	2009/02/04 12:47:05	1.1035
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Add support for ext4 resize in fsadm
   Move locking_type reading inside init_locking().
   Rename get_vgs() to get_vgnames() and clarify related error messages.
   Allow clvmd to be built with all cluster managers & select one on cmdline.
--- LVM2/man/fsadm.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/fsadm.8.in	2009/02/04 12:47:05	1.2
@@ -9,42 +9,48 @@
 .RI [options]\ resize\ device\ [new_size[BKMGTEP]]
 
 .SH "DESCRIPTION"
-\fBfsadm\fR utility resizes or checks the filesystem on a device. It tries to use the same API for \fBExt2/3\fR, \fBReiserFS\fR and \fBXFS\fR filesystem and simply resize and filesystem check operation.
+\fBfsadm\fR utility resizes or checks the filesystem on a device.
+It tries to use the same API for \fBext2/ext3/ext4\fR,
+\fBReiserFS\fR and \fBXFS\fR filesystem.
 .SH "OPTIONS"
-.TP 
+.TP
 \fB\-h \-\-help\fR
 \(em print help message
-.TP 
+.TP
 \fB\-v \-\-verbose\fR
 \(em be more verbose
-.TP 
+.TP
 \fB\-e \-\-ext\-offline\fR
-\(em unmount Ext2/3 filesystem before doing resize
-.TP 
+\(em unmount ext2/ext3/ext4 filesystem before doing resize
+.TP
 \fB\-f \-\-force\fR
 \(em bypass some sanity checks
-.TP 
+.TP
 \fB\-n \-\-dry\-run\fR
 \(em print commands without running them
-.TP 
+.TP
 \fB\-y \-\-yes\fR
 \(em answer "yes" at any prompts
-.TP  
+.TP
 \fBnew_size\fR
-\(em Absolute number of filesystem blocks to be in the filesystem, or an absolute size using a suffix (in powers of 1024). If new_size is not supplied, the whole device is used.
-
+\(em Absolute number of filesystem blocks to be in the filesystem,
+or an absolute size using a suffix (in powers of 1024).
+If new_size is not supplied, the whole device is used.
 
 .SH "EXAMPLES"
-"fsadm \-e \-y resize /dev/vg/test 1000M" tries to resize the size of the filesystem on logical volume /dev/vg/test. If /dev/vg/test contains Ext2/3 filesystem it will be unmounted prior the resize. All [y|n] questions will be answered 'y'.
+"fsadm \-e \-y resize /dev/vg/test 1000M" tries to resize the filesystem
+on logical volume /dev/vg/test. If /dev/vg/test contains ext2/ext3/ext4
+filesystem it will be unmounted prior the resize.
+All [y|n] questions will be answered 'y'.
 .SH "ENVIRONMENT VARIABLES"
-.TP 
-\fBTMPDIR\fP 
+.TP
+\fBTMPDIR\fP
 Where the temporary directory should be created.
-.TP 
-.BR 
+.TP
+.BR
 .SH "SEE ALSO"
-.BR lvm (8), 
-.BR lvresize (8), 
+.BR lvm (8),
+.BR lvresize (8),
 .BR lvm.conf (5),
 .BR tune2fs (8),
 .BR resize2fs (8),
@@ -53,4 +59,3 @@
 .BR xfs_info (8),
 .BR xfs_growfs (8),
 .BR xfs_check (8)
-
--- LVM2/scripts/fsadm.sh	2008/04/29 15:58:24	1.7
+++ LVM2/scripts/fsadm.sh	2009/02/04 12:47:05	1.8
@@ -19,7 +19,7 @@
 # Needed utilities:
 #   mount, umount, grep, readlink, blockdev, blkid, fsck, xfs_check
 #
-# ext2/ext3: resize2fs, tune2fs
+# ext2/ext3/ext4: resize2fs, tune2fs
 # reiserfs: resize_reiserfs, reiserfstune
 # xfs: xfs_growfs, xfs_info
 #
@@ -80,7 +80,7 @@
 	echo "  Options:"
 	echo "    -h | --help         Show this help message"
 	echo "    -v | --verbose      Be verbose"
-	echo "    -e | --ext-offline  unmount filesystem before Ext2/3 resize"
+	echo "    -e | --ext-offline  unmount filesystem before ext2/ext3/ext4 resize"
 	echo "    -f | --force        Bypass sanity checks"
 	echo "    -n | --dry-run      Print commands without running them"
 	echo "    -l | --lvresize     Resize given device (if it is LVM device)"
@@ -226,7 +226,7 @@
 	test -n "$BLOCKSIZE" -a -n "$BLOCKCOUNT" || error "Cannot parse $1 output"
 }
 ####################################
-# Resize ext2/ext3 filesystem
+# Resize ext2/ext3/ext4 filesystem
 # - unmounted or mounted for upsize
 # - unmounted for downsize
 ####################################
@@ -329,7 +329,7 @@
 	#IFS=$'\n'  # don't use bash-ism ??
 	IFS="$(printf \"\\n\")"  # needed for parsing output
 	case "$FSTYPE" in
-	  "ext3"|"ext2") resize_ext $NEWSIZE ;;
+	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool" ;;


