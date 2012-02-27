From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:32:48 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120227113248.4694.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:32:48

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	Check id_write_format result
	
	Currently we never fail with 64byte uuid buffer,
	but just stay consitent with rest of the code and check for result.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/cache/lvmetad.c	2012/02/26 13:42:50	1.6
+++ LVM2/lib/cache/lvmetad.c	2012/02/27 11:32:48	1.7
@@ -153,7 +153,8 @@
 		return NULL;
 
 	if (vgid) {
-		id_write_format((const struct id*)vgid, uuid, 64);
+		if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
+			return_0;
 		reply = daemon_send_simple(_lvmetad, "vg_lookup", "uuid = %s", uuid, NULL);
 	} else {
 		if (!vgname)
@@ -293,7 +294,9 @@
 	if (!_using_lvmetad)
 		return 1; /* just fake it */
 
-	id_write_format(&vg->id, uuid, 64);
+	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
+		return_0;
+
 	reply = daemon_send_simple(_lvmetad, "vg_remove", "uuid = %s", uuid, NULL);
 
 	return _lvmetad_handle_reply(reply, "remove VG", vg->name);
@@ -309,7 +312,8 @@
 	if (!_using_lvmetad)
 		return_0;
 
-	id_write_format(&pvid, uuid, 64);
+	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
+		return_0;
 
 	reply = daemon_send_simple(_lvmetad, "pv_lookup", "uuid = %s", uuid, NULL);
 
@@ -482,7 +486,8 @@
 	if (!_using_lvmetad)
 		return 1;
 
-	id_write_format(&pvid, uuid, 64);
+	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
+                return_0;
 
 	/* FIXME A more direct route would be much preferable. */
 	if ((info = lvmcache_info_from_pvid((const char *)&pvid, 0)))


