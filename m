From: James Cameron <james.cameron@hp.com>
Date: Fri, 11 May 2007 11:28:43 +1000
Subject: [PATCH] vgcfgrestore man page fix
Message-ID: <20070511012843.GA7222@hp.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Trivial fix, the man page suggests the volume group name is optional and
may be repeated, but the program will only accept one name.  This patch
corrects the man page.

--- LVM2.2.02.21/man/vgcfgrestore.8.orig	2007-05-11 11:07:54.000000000 +1000
+++ LVM2.2.02.21/man/vgcfgrestore.8	2007-05-11 11:10:18.000000000 +1000
@@ -11,11 +11,11 @@
 .RB [ \-n | \-\-name " VolumeGroupName" ]
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

Reference: HP 3218735444-322

-- 
James Cameron                         http://quozl.netrek.org/
HP Open Source, Volunteer             http://opensource.hp.com/
PPTP Client Project, Release Engineer http://pptpclient.sourceforge.net/


