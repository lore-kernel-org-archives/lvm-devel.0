From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:38 +0000 (GMT)
Subject: main - device_mapper: reduce min_size for flatten
Message-ID: <20210302215838.3F10F3851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67790d7e3bcfb202eb42d23ab36dfdfe31713996
Commit:        67790d7e3bcfb202eb42d23ab36dfdfe31713996
Parent:        73bea16c92cf6702a05634d80218297cb953ff36
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 21:22:41 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:57:35 2021 +0100

device_mapper: reduce min_size for flatten

For most ioctl() we do not need to pass so big buffers
and we can reduce amount of zeroed memory blocks.
---
 device_mapper/ioctl/libdm-iface.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 116fa3dc1..906d84b4e 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -1118,7 +1118,7 @@ static int _add_params(int type)
 
 static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 {
-	const size_t min_size = 16 * 1024;
+	size_t min_size;
 	const int (*version)[3];
 
 	struct dm_ioctl *dmi;
@@ -1137,6 +1137,18 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	else if (dmt->head)
 		log_debug_activation(INTERNAL_ERROR "dm '%s' ioctl should not define parameters.",
 				     _cmd_data_v4[dmt->type].name);
+	switch (dmt->type) {
+	case DM_DEVICE_CREATE:
+	case DM_DEVICE_DEPS:
+	case DM_DEVICE_INFO:
+	case DM_DEVICE_LIST:
+	case DM_DEVICE_STATUS:
+	case DM_DEVICE_TABLE:
+	case DM_DEVICE_TARGET_MSG:
+		min_size = 16 * 1024;
+	default:
+		min_size = 2 * 1024;
+	}
 
 	if (count && (dmt->sector || dmt->message)) {
 		log_error("targets and message are incompatible");


