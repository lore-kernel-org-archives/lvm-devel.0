From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 28 Jul 2010 12:12:54 +0200
Subject: [PATCH] Revert unsuccessful table load preparation in combined "create, load and resume" scenario
Message-ID: <4C5002A6.1050705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Per discussion with Zdenek, there's missing "revert" call in
_create_and_load_v4 fn while the preparation for table load ends
up with failure in create/load/resume sequence. Otherwise we could
end up with a device being created, but not table-loaded nor
resumed.

Even though the table is not loaded and the device is not resumed
at this stage, we still need to synchronize with udev when calling
the revert "remove" ioctl - there's still a remove uevent generated!
Current "revert" code does exactly that.

Peter
---
 libdm/ioctl/libdm-iface.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 5f71098..50cdec8 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1655,14 +1655,16 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	if (!(task = dm_task_create(DM_DEVICE_RELOAD))) {
 		log_error("Failed to create device-mapper task struct");
 		_udev_complete(dmt);
-		return 0;
+		r = 0;
+		goto revert;
 	}
 
 	/* Copy across relevant fields */
 	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
 		dm_task_destroy(task);
 		_udev_complete(dmt);
-		return 0;
+		r = 0;
+		goto revert;
 	}
 
 	task->read_only = dmt->read_only;


