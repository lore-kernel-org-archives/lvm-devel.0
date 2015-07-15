From: Mathias Krause <mathias.krause@secunet.com>
Date: Wed, 15 Jul 2015 09:27:56 +0200
Subject: [PATCH] libdm: mark control fd as close-on-exec
Message-ID: <1436945276-18080-1-git-send-email-mathias.krause@secunet.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The control fd should be marked as close-on-exec to avoid file
descriptor leaks in forking applications executing other programs.

Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
---
 libdm/ioctl/libdm-iface.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index e3b33b805e93..86fbc5f2c4ba 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -385,11 +385,24 @@ static void _close_control_fd(void)
 #ifdef DM_IOCTLS
 static int _open_and_assign_control_fd(const char *control)
 {
+#ifdef O_CLOEXEC
+	/*
+	 * O_CLOEXEC is supported since v2.6.23, so this may fail on old
+	 * kernels. Nonetheless favour it to a two staged approach as it's
+	 * atomic.
+	 */
+	if ((_control_fd = open(control, O_RDWR | O_CLOEXEC)) >= 0)
+		return 0;
+#endif
+
 	if ((_control_fd = open(control, O_RDWR)) < 0) {
 		log_sys_error("open", control);
 		return 0;
 	}
 
+	if (fcntl(_control_fd, F_SETFD, FD_CLOEXEC))
+		log_sys_error("fcntl", "setting FD_CLOEXEC");
+
 	return 1;
 }
 #endif
-- 
2.1.4


