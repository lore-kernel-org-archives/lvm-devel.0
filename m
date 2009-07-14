From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 02:19:20 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20090714021920.8091.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 02:19:19

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Remove READ_REQUIRE_RESIZEABLE flag from vg_read() interface - no users.
	
	The checks for RESIZEABLE_VG should now be inside the various functions that
	have to do such operations.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1179&r2=1.1180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.249&r2=1.250

--- LVM2/WHATS_NEW	2009/07/13 23:16:17	1.1179
+++ LVM2/WHATS_NEW	2009/07/14 02:19:19	1.1180
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Refactor vgsplit and vgextend to remove READ_REQUIRE_RESIZEABLE flag.
   Changed exit() to _exit() after fork(); avoid flushing libc buffers twice.
   Fixed invalid type being passed as printf argument on Sparc64.
   Make cmd->cmd_line const.
--- LVM2/lib/metadata/metadata-exported.h	2009/07/14 02:15:21	1.91
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/14 02:19:19	1.92
@@ -104,7 +104,6 @@
 /* vg_read and vg_read_for_update flags */
 #define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
-#define READ_REQUIRE_RESIZEABLE	0x00040000U
 
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE 	0x00100000U
--- LVM2/lib/metadata/metadata.c	2009/07/14 02:16:05	1.249
+++ LVM2/lib/metadata/metadata.c	2009/07/14 02:19:19	1.250
@@ -2994,9 +2994,6 @@
 	if (flags & READ_ALLOW_EXPORTED)
 		status &= ~EXPORTED_VG;
 
-	if (flags & READ_REQUIRE_RESIZEABLE)
-		status |= RESIZEABLE_VG;
-
 	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags);
 }
 


