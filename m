From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:26 +0000 (GMT)
Subject: main - device_mapper: keep bigger size for most ioctls
Message-ID: <20210310003626.37417385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2616cd45670866b4f5b46675fe3f1563eea3415
Commit:        b2616cd45670866b4f5b46675fe3f1563eea3415
Parent:        d2a3bfe6ca75f151a9fa37276dc0f8e3e6dc4ba4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 14:58:09 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:07:16 2021 +0100

device_mapper: keep bigger size for most ioctls

Actually the idea was to keep 2K ioctl only for certain command,
so keep 16 for them.
---
 device_mapper/ioctl/libdm-iface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 906d84b4e..6b3818e3a 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -1140,12 +1140,12 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
 	case DM_DEVICE_DEPS:
-	case DM_DEVICE_INFO:
 	case DM_DEVICE_LIST:
 	case DM_DEVICE_STATUS:
 	case DM_DEVICE_TABLE:
 	case DM_DEVICE_TARGET_MSG:
 		min_size = 16 * 1024;
+		break;
 	default:
 		min_size = 2 * 1024;
 	}


