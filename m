From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 10 Apr 2012 12:26:29 -0000
Subject: LVM2/lib cache/lvmetad.c format_text/format-text.c
Message-ID: <20120410122629.30836.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-04-10 12:26:27

Modified files:
	lib/cache      : lvmetad.c 
	lib/format_text: format-text.c 

Log message:
	Check if info struct returned is not NULL.
	
	Just some missing checks revealed by Coverity in recent code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.199&r2=1.200

--- LVM2/lib/cache/lvmetad.c	2012/03/14 17:15:22	1.19
+++ LVM2/lib/cache/lvmetad.c	2012/04/10 12:26:27	1.20
@@ -138,8 +138,9 @@
 	if (!vgname)
 		vgname = fmt->orphan_vg_name;
 
-	info = lvmcache_add(fmt->labeller, (const char *)&pvid, device,
-			    vgname, (const char *)&vgid, 0);
+	if (!(info = lvmcache_add(fmt->labeller, (const char *)&pvid, device,
+				  vgname, (const char *)&vgid, 0)))
+		return_NULL;
 
 	lvmcache_get_label(info)->sector = label_sector;
 	lvmcache_set_device_size(info, devsize);
--- LVM2/lib/format_text/format-text.c	2012/03/02 20:46:37	1.199
+++ LVM2/lib/format_text/format-text.c	2012/04/10 12:26:27	1.200
@@ -1455,6 +1455,9 @@
 		info = label->info;
 	}
 
+	if (!info)
+		return_0;
+
 	if (!lvmcache_populate_pv_fields(info, pv, scan_label_only))
 		return 0;
 


