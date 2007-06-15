From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jun 2007 16:05:58 -0000
Subject: LVM2 ./WHATS_NEW man/vgcfgrestore.8
Message-ID: <20070615160558.2022.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-15 16:05:57

Modified files:
	.              : WHATS_NEW 
	man            : vgcfgrestore.8 

Log message:
	Update vgcfgrestore man pg

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.633&r2=1.634
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgrestore.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2007/06/15 10:11:14	1.633
+++ LVM2/WHATS_NEW	2007/06/15 16:05:57	1.634
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Update vgcfgrestore man page.
   Allow keyboard interrupt in user prompts where appropriate.
   Remove system-lv code from clvmd. It's highly dodgy and never used.
   Convert a lot of code pv dereferences to use get_pv_* functions.
--- LVM2/man/vgcfgrestore.8	2007/05/22 02:52:57	1.3
+++ LVM2/man/vgcfgrestore.8	2007/06/15 16:05:57	1.4
@@ -10,12 +10,24 @@
 .RB [ \-M | \-\-Metadatatype 1|2]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
-.RI VolumeGroupName
+.RI \fIVolumeGroupName\fP
 .SH DESCRIPTION
 .B vgcfgrestore
-allows you to restore the metadata 
-of a volume group from a text backup file produced by \fBvgcfgbackup\fP.
+allows you to restore the metadata of \fIVolumeGroupName\fP from a text 
+backup file produced by \fBvgcfgbackup\fP.  You can specify a backup file to
+use with the \fP-f\fP option.  If no backup file is specified, the latest
+backup file is used.  A list of backup and archive files of 
+\fIVolumeGroupName\fP may be listed with the \fB-l\fP option.
 .SH OPTIONS
+.TP
+\fB-l | --list\fP \(em List files pertaining to \fIVolumeGroupName\fP
+List metadata backup and archive files pertaining to \fIVolumeGroupName\fP.
+May be used with the \fB-f\fP option.  Does not restore \fIVolumeGroupName\fP.
+.TP
+\fB-f | --file\fP filename \(em Name of LVM metadata backup file
+Specifies a metadata backup or archive file to be used for restoring 
+VolumeGroupName.  Often this file has been created with \fBvgcfgbackup\fP.
+.TP
 See \fBlvm\fP for common options.
 .SH REPLACING PHYSICAL VOLUMES
 \fBvgdisplay --partial --verbose\fP will show you the UUIDs and sizes of


