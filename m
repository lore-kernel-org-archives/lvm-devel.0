From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:28 +0100
Subject: [PATCH 04/15] Move add_dev_node to DM_DEVICE_RESUME
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <9a4c2260ad7d096250dbb19a28bad8f05f37920b.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch came out from discussion with Petr.
We need valid 'check_udev' for stacked ops processing.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 92c8e9e..c3df610 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -2070,10 +2070,6 @@ repeat_ioctl:
 
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
-		if (dmt->dev_name && *dmt->dev_name && !udev_only)
-			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
-				     MINOR(dmi->dev), dmt->uid, dmt->gid,
-				     dmt->mode, check_udev);
 		break;
 	case DM_DEVICE_REMOVE:
 		/* FIXME Kernel needs to fill in dmi->name */
@@ -2089,6 +2085,10 @@ repeat_ioctl:
 		break;
 
 	case DM_DEVICE_RESUME:
+		if (dmt->dev_name && *dmt->dev_name && !udev_only)
+			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
+				     MINOR(dmi->dev), dmt->uid, dmt->gid,
+				     dmt->mode, check_udev);
 		/* FIXME Kernel needs to fill in dmi->name */
 		set_dev_node_read_ahead(dmt->dev_name, dmt->read_ahead,
 					dmt->read_ahead_flags);
-- 
1.7.3.5


