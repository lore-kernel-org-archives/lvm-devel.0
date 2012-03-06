From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Mar 2012 09:22:03 -0000
Subject: LVM2 ./WHATS_NEW man/lvcreate.8.in tools/lvcre ...
Message-ID: <20120306092203.17171.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-06 09:22:03

Modified files:
	.              : WHATS_NEW 
	man            : lvcreate.8.in 
	tools          : lvcreate.c 

Log message:
	Fix warn message and update man page
	
	Fix regression in man page. The chunk size is in kilobyte units on command line
	input though in the source code we work with sector size unit
	so make it clear in the man page.
	
	Update chunksize for thin pool in man page - it's max value is 1024M == 1G.
	
	Fix warning range message to show proper max value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2348&r2=1.2349
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.262&r2=1.263

--- LVM2/WHATS_NEW	2012/03/06 04:47:37	1.2348
+++ LVM2/WHATS_NEW	2012/03/06 09:22:02	1.2349
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix warn msg for thin pool chunk size and update man for chunksize (2.02.89).
 
 Version 2.02.95 - 6th March 2012
 ================================
--- LVM2/man/lvcreate.8.in	2012/01/20 10:50:39	1.35
+++ LVM2/man/lvcreate.8.in	2012/03/06 09:22:02	1.36
@@ -120,11 +120,14 @@
 on one node and \fB-a\fIly\fR will activate only on the local node.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize
-Power of 2 chunk size in sector units (512b).
-For snapshot logical volume the value must be between 8 (4KB) and 1024 (512KB)
-and the default value is 8.
-For thin pool logical volume the value must be between 128 (64KB) and
-2097152 (1MB) and the default value is 128.
+Gives the size of chunk for snapshot and thin pool logical volumes.
+For snapshots the value must be power of 2 between 4KiB and 512KiB
+and the default value is 4.
+For thin pools the value must be power of 2 between 64KiB and
+1048576KiB and the default value starts with 64 and scales
+up to fit the pool metadata size within 128MB, 
+if the poolmetadata size is not specified.
+Default unit is in kilobytes.
 .TP
 .BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
 Sets or resets the contiguous allocation policy for
--- LVM2/tools/lvcreate.c	2012/03/06 02:30:50	1.262
+++ LVM2/tools/lvcreate.c	2012/03/06 09:22:03	1.263
@@ -772,13 +772,15 @@
 				return 0;
 			}
 		} else {
-			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, DM_THIN_MIN_DATA_BLOCK_SIZE);
+			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG,
+							DM_THIN_MIN_DATA_BLOCK_SIZE);
 			if ((lp->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 			    (lp->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) ||
 			    (lp->chunk_size & (lp->chunk_size - 1))) {
 				log_error("Chunk size must be a power of 2 in the "
-					  "range %uK to %uK", (DM_THIN_MIN_DATA_BLOCK_SIZE / 2),
-					  (DM_THIN_MIN_DATA_BLOCK_SIZE / 2));
+					  "range %uK to %uK",
+					  (DM_THIN_MIN_DATA_BLOCK_SIZE / 2),
+					  (DM_THIN_MAX_DATA_BLOCK_SIZE / 2));
 				return 0;
 			}
 		}


