From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:13:49 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv.c
Message-ID: <20120227111349.28272.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:13:48

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv.c 

Log message:
	Fix missing break
	
	Bug introduced with addition of internal error default case.
	Seem like this code is not used.
	TODO: add coverage test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2314&r2=1.2315
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2012/02/27 10:15:08	1.2314
+++ LVM2/WHATS_NEW	2012/02/27 11:13:48	1.2315
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Fix missing break in _format_pvsegs (2.02.92).
   Test seg pointer for non-null it in raid_target_percent error path.
   Check for errors in _init_tags() during config loading.
   Always check result of _set_vg_name() in lvcreate.
--- LVM2/lib/metadata/lv.c	2012/02/23 22:31:23	1.38
+++ LVM2/lib/metadata/lv.c	2012/02/27 11:13:48	1.39
@@ -53,6 +53,7 @@
 		case AREA_UNASSIGNED:
 			name = "unassigned";
 			extent = 0;
+			break;
 		default:
 			log_error(INTERNAL_ERROR "Unknown area segtype.");
 			return NULL;


