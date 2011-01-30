From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:27 +0100
Subject: [PATCH 04/24] Move add_dev_node to DM_DEVICE_RESUME
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <56ba2c0e512202d41243c1ac211bb2efa399eb9b.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch came out from discussion with Petr.
We need valid 'check_udev' for stacked ops processing.

Current code:

dmsetup create xxx --notable   ->  create node in /dev/mapper/xxx

(check_udev has incorrect 0 value)

**

New patched code creates node with:

dmsetup resume xxx

(As just at this moment udev is registering such device)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 25714ce..4e01bcf 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -2061,10 +2061,6 @@ repeat_ioctl:
 
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
-		if (dmt->dev_name && *dmt->dev_name && !udev_only)
-			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
-				     MINOR(dmi->dev), dmt->uid, dmt->gid,
-				     dmt->mode, check_udev);
 		break;
 	case DM_DEVICE_REMOVE:
 		/* FIXME Kernel needs to fill in dmi->name */
@@ -2080,6 +2076,10 @@ repeat_ioctl:
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


