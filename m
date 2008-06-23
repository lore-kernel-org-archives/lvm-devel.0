From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jun 2008 19:26:21 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-md.c
Message-ID: <20080623192621.22111.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-23 19:26:21

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-md.c 

Log message:
	Suppress invalid 'sb_offset' compiler warning (FC8) with uninitialized_var().
	
	device/dev-md.c:61: warning: ???sb_offset??? may be used uninitialized in this function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.913&r2=1.914
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2008/06/23 19:04:34	1.913
+++ LVM2/WHATS_NEW	2008/06/23 19:26:20	1.914
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Suppress invalid 'sb_offset' compiler warning with uninitialzed_var().
   Add uninitialzed_var() macro to suppress invalid compiler warnings.
   Suppress 'sb_offset' compiler warning by using enum for md minor sb version. 
   lvm2_run: Don't return uninitialized "ret" for _memlock_inc or _memlock_dec.
--- LVM2/lib/device/dev-md.c	2008/06/23 14:54:50	1.9
+++ LVM2/lib/device/dev-md.c	2008/06/23 19:26:21	1.10
@@ -58,7 +58,7 @@
 
 static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 {
-	uint64_t sb_offset;
+	uint64_t uninitialized_var(sb_offset);
 
 	switch(minor_version) {
 	case MD_MINOR_V0:


