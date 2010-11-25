From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:15 +0100
Subject: [PATCH 11/29] Add stack trace for error path
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <0c942670df4d53c9c6581513a8a7c0ef10eda778.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If dm_task_set_cookie fail - print stack trace, but keep going on.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 147eec2..431aa8f 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1776,9 +1776,10 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	if (dmt->cookie_set) {
 		cookie = (dmt->event_nr & ~DM_UDEV_FLAGS_MASK) |
 			 (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
-		dm_task_set_cookie(dmt, &cookie,
-				   (dmt->event_nr & DM_UDEV_FLAGS_MASK) >>
-				    DM_UDEV_FLAGS_SHIFT);
+		if (!dm_task_set_cookie(dmt, &cookie,
+					(dmt->event_nr & DM_UDEV_FLAGS_MASK) >>
+					DM_UDEV_FLAGS_SHIFT))
+                        stack; /* keep going */
 	}
 
 	if (!dm_task_run(dmt))
-- 
1.7.3.2


