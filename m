From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 11:09:07 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120228110907.2177.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 11:09:06

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	Check result of export_vg_to_buffer
	
	and avoid usage of failed buffer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/lib/cache/lvmetad.c	2012/02/27 11:32:48	1.7
+++ LVM2/lib/cache/lvmetad.c	2012/02/28 11:09:06	1.8
@@ -518,7 +518,11 @@
 		 * formatted and has no conflicting keys with the rest of the
 		 * request.
 		 */
-		export_vg_to_buffer(vg, &buf);
+		if (!export_vg_to_buffer(vg, &buf)) {
+			dm_free(pvmeta);
+			return_0;
+		}
+
 		reply = daemon_send_simple(_lvmetad,
 					   "pv_found",
 					   "pvmeta = %b", pvmeta,


