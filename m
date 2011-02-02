From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Feb 2011 14:07:58 +0100
Subject: [PATCH 2/5] Move add_dev_node to DM_DEVICE_RESUME
In-Reply-To: <cover.1296651808.git.zkabelac@redhat.com>
References: <cover.1296651808.git.zkabelac@redhat.com>
Message-ID: <828d5d5cea5e574804c8aedbf252e9f566a006d7.1296651808.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch came out from discussion with Petr.
We need valid 'check_udev' for stacked ops processing.

==

Current code:

dmsetup create xxx --notable   ->  create node in /dev/mapper/xxx

(check_udev has incorrect 0 value) and we are forcing node
creation in /dev directory - while only udevd should have
full control over the nodes available there.

(i.e. selinux policy might allo creation only in udev process)

==

New code creates /dev/mapper node with:

dmsetup resume xxx

As just at this moment udev is registering such device through
a CHANGE event.

==

This patch is causing incompatibilities with some old
hand written scripts which may relay on existance of device node
even when such node has only empty table.

But the functionality is needed for following patch which prunes
operation on the same node when they are all combined within one
udev cookie transaction.

We cannot insert there 'ADD' operation which pretends it should not
check for udev and mix them with udev operation - as we would again
modify content of /dev dir.

Also this patch allows to further cleanup libdevmapper code
from other quirks.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index fbe4b14..bb9dac5 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -2064,10 +2064,6 @@ repeat_ioctl:
 
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
-		if (dmt->dev_name && *dmt->dev_name && !udev_only)
-			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
-				     MINOR(dmi->dev), dmt->uid, dmt->gid,
-				     dmt->mode, check_udev);
 		break;
 	case DM_DEVICE_REMOVE:
 		/* FIXME Kernel needs to fill in dmi->name */
@@ -2083,6 +2079,10 @@ repeat_ioctl:
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


