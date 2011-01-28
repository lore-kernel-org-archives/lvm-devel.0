From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 10:14:09 -0000
Subject: LVM2 ./WHATS_NEW lib/uuid/uuid.c
Message-ID: <20110128101409.30443.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 10:14:09

Modified files:
	.              : WHATS_NEW 
	lib/uuid       : uuid.c 

Log message:
	Avoid rebuilding of uuid validation table
	
	Small CPU relax...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1893&r2=1.1894
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2011/01/28 02:58:00	1.1893
+++ LVM2/WHATS_NEW	2011/01/28 10:14:08	1.1894
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Avoid rebuilding of uuid validation table.
   Always use O_DIRECT when opening block devices to check for partitioning.
   Improve lvcreate "insufficient extents" errors to "insufficient free space".
 
--- LVM2/lib/uuid/uuid.c	2010/09/30 14:07:33	1.31
+++ LVM2/lib/uuid/uuid.c	2011/01/28 10:14:09	1.32
@@ -125,6 +125,7 @@
 	if (_built_inverse)
 		return;
 
+	_built_inverse = 1;
 	memset(_inverse_c, 0, sizeof(_inverse_c));
 
 	for (ptr = _c; *ptr; ptr++)


