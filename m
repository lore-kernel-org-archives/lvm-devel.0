From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:58:39 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20111221135839.20607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:58:39

Modified files:
	man            : lvcreate.8.in 

Log message:
	Thin man page update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/man/lvcreate.8.in	2011/11/10 12:41:39	1.33
+++ LVM2/man/lvcreate.8.in	2011/12/21 13:58:38	1.34
@@ -52,7 +52,6 @@
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-t | \-\-test ]
 .RB [ \-T | \-\-thin
-.RI [ ThinPoolLogicalVolume { Name | Path }]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
 .RB [ \-\-poolmetadatasize
@@ -277,7 +276,7 @@
 .TP
 .B \-\-type \fISegmentType
 Create a logical volume that uses the specified segment type
-(e.g. "raid5", "mirror", "snapshot", "thin", "thin_pool").
+(e.g. "raid5", "mirror", "snapshot", "thin", "thin-pool").
 Many segment types have a
 commandline switch alias that will enable their use (-s is an alias for
 --type snapshot).  However, this argument must be used when no existing


