From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Apr 2009 20:11:49 -0000
Subject: LVM2 man/lvcreate.8.in tools/lvconvert.c
Message-ID: <20090429201149.23264.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-04-29 20:11:46

Modified files:
	man            : lvcreate.8.in 
	tools          : lvconvert.c 

Log message:
	Fixup whitespace.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/man/lvcreate.8.in	2009/04/25 01:18:00	1.4
+++ LVM2/man/lvcreate.8.in	2009/04/29 20:11:46	1.5
@@ -25,7 +25,7 @@
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
  \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
 [\-c|\-\-chunksize ChunkSize]
-\-n|\-\-name SnapshotLogicalVolumeName 
+\-n|\-\-name SnapshotLogicalVolumeName
 \-s|\-\-snapshot
 [OriginalLogicalVolumePath | VolumeGroupName \-\-virtualoriginsize VirtualOriginSize]
 .SH DESCRIPTION
--- LVM2/tools/lvconvert.c	2009/04/23 16:56:22	1.71
+++ LVM2/tools/lvconvert.c	2009/04/29 20:11:46	1.72
@@ -505,13 +505,13 @@
 				  lv->name, existing_mirrors);
 			return 0;
 		}
-		
+
 		/*
 		 * Adjust log type
 		 */
 		if (arg_count(cmd, corelog_ARG))
 			corelog = 1;
-		
+
 		mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
 					  corelog ? "core" : DEFAULT_MIRRORLOG);
 		if (!strcmp("disk", mirrorlog)) {
@@ -551,7 +551,7 @@
 			  "mirror segments.", lv->name);
 		return 0;
 	}
-	
+
  restart:
 	/*
 	 * Converting from mirror to linear
@@ -579,7 +579,7 @@
 		/*
 		 * Converting from linear to mirror
 		 */
-	
+
 		/* FIXME Share code with lvcreate */
 
 		/* FIXME Why is this restriction here?  Fix it! */


