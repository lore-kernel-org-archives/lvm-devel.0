From: Milan Broz <mbroz@redhat.com>
Date: Fri, 18 Mar 2011 12:32:17 +0100
Subject: [PATCH] Mitigate some warnings if running as non-root user.
Message-ID: <1300447937-8114-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

LVM doesn't behave correctly if running as non-root user,
there is warning when it detects it.

Despite this, it produces many error messages, saying nothing.
See https://bugzilla.redhat.com/show_bug.cgi?id=620571

This patch fixes two things:
1) Removes eror message from device_is_usable() which has no
information value anyway (real warning is printed inside it).

2) it fixes device-mapper initialization, if we support
core dm module autoload and device node is present, it should
fail early and not try recreate existing and correct node.
(non-root == permission denied here)

N.B. In future code should support user roles, some more
drastic checks in code are probably contraproductive now.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/dev_manager.c |    6 ++----
 libdm/ioctl/libdm-iface.c  |    9 ++++++---
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 865bb35..cb041c6 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -141,10 +141,8 @@ int device_is_usable(struct device *dev)
 	int only_error_target = 1;
 	int r = 0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
-		log_error("Failed to create dm_task struct to check dev status");
-		return 0;
-	}
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+		return_0;
 
 	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
 		goto_out;
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 241e792..b52c925 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -365,8 +365,9 @@ static int _open_and_assign_control_fd(const char *control,
 	_close_control_fd();
 
 	if ((_control_fd = open(control, O_RDWR)) < 0) {
-		if (!(ignore_nodev && errno == ENODEV))
-			log_sys_error("open", control);
+		if (ignore_nodev && errno == ENODEV)
+			return 1;
+		log_sys_error("open", control);
 		return 0;
 	}
 
@@ -412,7 +413,9 @@ static int _open_control(void)
 		    !_create_control(control, major, MAPPER_CTRL_MINOR))
 			goto error;
 
-		_open_and_assign_control_fd(control, 1);
+		/* Fallback to old code only if control node doesn't exist */
+		if (!_open_and_assign_control_fd(control, 1))
+			goto error;
 	}
 
 	/*
-- 
1.7.4.1


