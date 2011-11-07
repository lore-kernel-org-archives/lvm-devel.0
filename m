From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Nov 2011 10:59:56 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20111107105956.10447.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-07 10:59:56

Modified files:
	man            : lvcreate.8.in 

Log message:
	Thin lvcreate poolmetadatasize units doc

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/man/lvcreate.8.in	2011/11/04 22:47:17	1.30
+++ LVM2/man/lvcreate.8.in	2011/11/07 10:59:55	1.31
@@ -93,7 +93,7 @@
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
 .RB [ \-\-poolmetadatasize
-.IR MetadataSize [ bBsSkKmMgGt ]]]
+.IR MetadataSize [ bBsSkKmMgG ]]]
 .RB [ \-\-thinpool
 .IR ThinPoolLogicalVolumeName [ Path ]]
 .RB [ \-V | \-\-virtualsize
@@ -240,6 +240,7 @@
 Set the size of thin pool's metadata logical volume.
 Supported value is in range between 2MiB and 16GiB.
 Default value is  (Pool_LV_size / Pool_LV_chunk_size * 64b).
+Default unit is megabytes.
 
 .TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }


