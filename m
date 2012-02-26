From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 26 Feb 2012 08:49:40 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120226084940.13917.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-26 08:49:40

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	- Improve error reporting on lvmetad connection failure.
	- Fix a couple of memory leaks in the lvmetad client code.
	- Avoid an error in lvmetad_pv_gone when we aren't using lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/lib/cache/lvmetad.c	2012/02/23 22:24:47	1.4
+++ LVM2/lib/cache/lvmetad.c	2012/02/26 08:49:40	1.5
@@ -16,8 +16,8 @@
 	const char *socket = getenv("LVM_LVMETAD_SOCKET");
 	if (_using_lvmetad) { /* configured by the toolcontext */
 		_lvmetad = lvmetad_open(socket ?: DEFAULT_RUN_DIR "/lvmetad.socket");
-		if (_lvmetad.socket_fd < 0) {
-			log_warn("Failed to connect to lvmetad. Falling back to scanning.");
+		if (_lvmetad.socket_fd < 0 || _lvmetad.error) {
+			log_warn("Failed to connect to lvmetad: %s. Falling back to scanning.", strerror(_lvmetad.error));
 			_using_lvmetad = 0;
 		}
 	}
@@ -251,6 +251,7 @@
 	reply = daemon_send_simple(_lvmetad, "vg_update", "vgname = %s", vg->name,
 				             "metadata = %b", strchr(buf, '{'),
 				   NULL);
+	dm_free(buf);
 
 	if (!_lvmetad_handle_reply(reply, "update VG", vg->name))
 		return 0;
@@ -496,8 +497,12 @@
 			 "  %s"
 			 "}", device->dev,
 			 info ? lvmcache_device_size(info) : 0,
-			 fmt->name, label_sector, uuid, mdas ?: ""))
+			 fmt->name, label_sector, uuid, mdas ?: "")) {
+		dm_free((char *)mdas);
 		return_0;
+	}
+
+	dm_free((char *)mdas);
 
 	if (vg) {
 		/*
@@ -529,6 +534,9 @@
 
 int lvmetad_pv_gone(dev_t device)
 {
+	if (!_using_lvmetad)
+		return 1;
+
 	daemon_reply reply =
 		daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
 


