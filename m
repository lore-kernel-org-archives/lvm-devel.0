From: Liuhua Wang <lwang@suse.com>
Date: Thu, 27 Aug 2015 16:30:41 +0800
Subject: [PATCH] libdm-iface: not output error message inside retry loops
Message-ID: <1440664241-6149-1-git-send-email-lwang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

    To avoid noisy error message being output inside retry loops
    in case of remove failure because device busy.
---
 libdm/ioctl/libdm-iface.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 73af12b..287e917 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -63,6 +63,8 @@
 #define MAPPER_CTRL_MINOR 236
 #define MISC_MAJOR 10
 
+#define DM_IOCTL_RETRIES 25
+
 /* dm major version no for running kernel */
 static unsigned _dm_version = DM_VERSION_MAJOR;
 static unsigned _dm_version_minor = 0;
@@ -1848,7 +1850,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 					    dmt->major > 0 && dmt->minor == 0 ? "0" : "",
 					    dmt->major > 0 ? ")" : "",
 					    strerror(dmt->ioctl_errno));
-			else
+			else if(dmt->ioctl_errno != EBUSY || retry_repeat_count == DM_IOCTL_RETRIES)
 				log_error("device-mapper: %s ioctl on %s%s%s%.0d%s%.0d%s%s "
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
@@ -1901,7 +1903,6 @@ void dm_task_update_nodes(void)
 	update_devs();
 }
 
-#define DM_IOCTL_RETRIES 25
 #define DM_RETRY_USLEEP_DELAY 200000
 
 int dm_task_get_errno(struct dm_task *dmt)
-- 
1.8.4.5


