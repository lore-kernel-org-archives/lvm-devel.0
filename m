From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 May 2009 14:19:29 +0200
Subject: [PATCH 8/9] Adapt _rename_dev_node for udev
Message-ID: <4A1A8CD1.6050607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This one is for _rename_dev_node -- if udev renames the node, this
code won't overwrite it once again. Also, if udev has done the
rename already, the old node does not exist anymore, so we have to
detect this somehow.

Peter


diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index ef249dc..90dd031 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -350,6 +350,10 @@ static int _rename_dev_node(const char *old_name, const char *new_name)
 				  "is already present", newpath);
 			return 0;
 		}
+		else if (stat(oldpath, &info) < 0 &&
+			 errno == ENOENT)
+			/* udev should have done this already */
+			return 1;
 
 		if (unlink(newpath) < 0) {
 			if (errno == EPERM) {


