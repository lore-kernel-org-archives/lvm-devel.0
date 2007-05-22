From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 May 2007 02:52:58 -0000
Subject: LVM2 ./WHATS_NEW man/vgcfgrestore.8
Message-ID: <20070522025258.6123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-05-22 02:52:58

Modified files:
	.              : WHATS_NEW 
	man            : vgcfgrestore.8 

Log message:
	Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.620&r2=1.621
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgrestore.8.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2007/05/22 02:51:33	1.620
+++ LVM2/WHATS_NEW	2007/05/22 02:52:57	1.621
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.
   Fix vgrename man page to include UUID and be consistent with lvrename.
   Add (experimental) OpenAIS support to clvmd.
   Remove symlinks if parent volume is deactivated.
--- LVM2/man/vgcfgrestore.8	2002/12/03 13:25:09	1.2
+++ LVM2/man/vgcfgrestore.8	2007/05/22 02:52:57	1.3
@@ -5,17 +5,16 @@
 .B vgcfgrestore
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-file " filename" ]
-.RB [ \-l[l] | \-\-list [--list] ]
+.RB [ \-l[l] | \-\-list ]
 .RB [ \-h | \-\-help ]
 .RB [ \-M | \-\-Metadatatype 1|2]
-.RB [ \-n | \-\-name " VolumeGroupName" ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
-.RI [ VolumeGroupName ...]
+.RI VolumeGroupName
 .SH DESCRIPTION
 .B vgcfgrestore
 allows you to restore the metadata 
-of your volume groups from a text backup file produced by \fBvgcfgbackup\fP.
+of a volume group from a text backup file produced by \fBvgcfgbackup\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH REPLACING PHYSICAL VOLUMES


