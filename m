From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 May 2009 14:19:21 +0200
Subject: [PATCH 7/9] Adapt _mk_link for udev
Message-ID: <4A1A8CC9.3040307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This one is a little bit tricky. Since udev now creates the nodes and
symlinks, they should not be overwritten if the links exist already.

Still, the question is how should we do this when udev notification
is disabled. It's only the notification that is disabled, not the udev
itself, we have no info about this. The problem is that we use
/dev/dm-X as nodes and /dev/mapper contents as symlinks now. When the
wait-for-udev is disabled and there's an existing symlink there,
it still behaves the old way... Which means that the symlink in
/dev/VG will point to /dev/mapper contents, not /dev/dm-X, just
like in the situation with the udev. It's not 100% consistent...
Need to think about this more if there's a better workaround for
this...

Peter


diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 6b83581..6a1fb60 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -161,11 +161,16 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 			return 0;
 		}
 
-		log_very_verbose("Removing %s", lv_path);
-		if (unlink(lv_path) < 0) {
-			log_sys_error("unlink", lv_path);
-			return 0;
+		if (!dm_udev_notif_is_enabled()) {
+			log_very_verbose("Removing %s", lv_path);
+			if (unlink(lv_path) < 0) {
+				log_sys_error("unlink", lv_path);
+				return 0;
+			}
 		}
+		else
+			/* udev should have done this already */
+			return 1;
 	}
 
 	log_very_verbose("Linking %s -> %s", lv_path, link_path);


