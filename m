From: Lukas Wunner <lukas@wunner.de>
Date: Tue, 2 Dec 2014 18:58:25 +0100
Subject: [PATCH] dmsetup: Set exit code to 1 if remove_all fails to remove all devices
Message-ID: <20141202175825.GA8489@wunner.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There are scripts out there which expect "dmsetup remove_all" to
not exit with 0 if some devices couldn't be removed, e.g. dracut:
https://git.kernel.org/cgit/boot/dracut/dracut.git/tree/modules.d/90dm/dm-shutdown.sh

Up until now the exit code of "dmsetup remove_all" is only non-zero
if the call to ioctl() fails, causing _do_dm_ioctl() to return NULL
instead of a struct dm_ioctl*.

Fix this by counting the remaining devices after the call to
_simple() even if --force is not used, and by returning success
only if the call to simple() was succesful AND no devices remain.

Signed-off-by: Lukas Wunner <lukas@wunner.de>
---
 tools/dmsetup.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4202dbb..77d7cf6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1528,27 +1528,23 @@ static int _remove_all(CMD_ARGS)
 	/* Remove all closed devices */
 	r =  _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
 
-	if (!_switches[FORCE_ARG])
-		return r;
-
 	_num_devices = 0;
-	r |= _process_all(cmd, argc, argv, 1, _count_devices);
+	r &= _process_all(cmd, argc, argv, 1, _count_devices);
 
-	/* No devices left? */
-	if (!_num_devices)
-		return r;
+	if ((r && !_num_devices) || !_switches[FORCE_ARG])
+		goto out;
 
 	r |= _process_all(cmd, argc, argv, 1, _error_device);
 	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
 
 	_num_devices = 0;
-	r |= _process_all(cmd, argc, argv, 1, _count_devices);
-	if (!_num_devices)
-		return r;
+	r &= _process_all(cmd, argc, argv, 1, _count_devices);
 
-	fprintf(stderr, "Unable to remove %d device(s).\n", _num_devices);
+out:
+	if (_num_devices)
+		fprintf(stderr, "Unable to remove %d device(s).\n", _num_devices);
 
-	return r;
+	return r && !_num_devices;
 }
 
 static void _display_dev(struct dm_task *dmt, const char *name)
-- 
1.8.5.2


