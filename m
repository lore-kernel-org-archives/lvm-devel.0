From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Oct 2010 09:13:14 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20101026091314.17474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-26 09:13:13

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Fix NULL pointer dereference for too large MDA error path
	
	Replace dereference of NULL vg with passed vgname to the function
	_vg_read_raw_area() in the error path for too large MDA.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1779&r2=1.1780
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/WHATS_NEW	2010/10/26 08:59:05	1.1779
+++ LVM2/WHATS_NEW	2010/10/26 09:13:13	1.1780
@@ -1,5 +1,6 @@
 Version 2.02.76
 ===================================
+  Fix NULL pointer dereference for too large MDA error path in _vg_read_raw_area().
   Use static for internal _align_chunk() and _new_chunk() from pool-fast.c.
   Fix vgchange to process -a, --refresh, --monitor and --poll like lvchange.
   Add lvm2app functions to query any pv, vg, or lv property / report field.
--- LVM2/lib/format_text/format-text.c	2010/10/05 17:34:06	1.147
+++ LVM2/lib/format_text/format-text.c	2010/10/26 09:13:13	1.148
@@ -507,7 +507,7 @@
 
 	if (wrap > rlocn->offset) {
 		log_error("VG %s metadata too large for circular buffer",
-			  vg->name);
+			  vgname);
 		goto out;
 	}
 


