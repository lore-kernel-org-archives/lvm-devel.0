From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jan 2008 17:01:42 -0000
Subject: LVM2/man fsadm.8
Message-ID: <20080108170142.12951.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-01-08 17:01:42

Added files:
	man            : fsadm.8 

Log message:
	added manpage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/fsadm.8.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/man/fsadm.8,v  -->  standard output
revision 1.1
--- LVM2/man/fsadm.8
+++ -	2008-01-08 17:01:42.332047000 +0000
@@ -0,0 +1,56 @@
+.TH "FSADM" "8" "LVM TOOLS" "Red Hat, Inc" "\""
+.SH "NAME"
+fsadm \- utility to resize or check filesystem on a device
+.SH "SYNOPSIS"
+.B fsdam
+.RI [options]\ check\ device
+
+.B fsdam
+.RI [options]\ resize\ device\ [new_size[BKMGTEP]]
+
+.SH "DESCRIPTION"
+\fBfsadm\fR utility resizes or checks the filesystem on a device. It tries to use the same API for \fBExt2/3\fR, \fBReiserFS\fR and \fBXFS\fR filesystem and simply resize and filesystem check operation.
+.SH "OPTIONS"
+.TP 
+\fB\-h \-\-help\fR
+\(em print help message
+.TP 
+\fB\-v \-\-verbose\fR
+\(em be more verbose
+.TP 
+\fB\-e \-\-ext\-offline\fR
+\(em unmount Ext2/3 filesystem before doing resize
+.TP 
+\fB\-f \-\-force\fR
+\(em bypass some sanity checks
+.TP 
+\fB\-n \-\-dry\-run\fR
+\(em print commands without running them
+.TP 
+\fB\-y \-\-yes\fR
+\(em answer "yes" at any prompts
+.TP  
+\fBnew_size\fR
+\(em Absolute number of filesystem blocks to be in the filesystem, or an absolute size using a suffix (in powers of 1024). If new_size is not supplied, the whole device is used.
+
+
+.SH "EXAMPLES"
+"fsadm \-e \-y resize /dev/vg/test 1000M" tries to resize the size of the filesystem on logical volume /dev/vg/test. If /dev/vg/test contains Ext2/3 filesystem it will be unmounted prior the resize. All [y|n] questions will be answered 'y'.
+.SH "ENVIRONMENT VARIABLES"
+.TP 
+\fBTMPDIR\fP 
+Where the temporary directory should be created.
+.TP 
+.BR 
+.SH "SEE ALSO"
+.BR lvm (8), 
+.BR lvresize (8), 
+.BR lvm.conf (5),
+.BR tune2fs (8),
+.BR resize2fs (8),
+.BR reiserfstune (8),
+.BR resize_reiserfs (8),
+.BR xfs_info (8),
+.BR xfs_growfs (8),
+.BR xfs_check (8)
+


