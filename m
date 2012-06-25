From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Jun 2012 09:56:47 +0000 (UTC)
Subject: master - dev-io: open device read-only to obtain readahead value
Message-ID: <20120625095647.C465B1706@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8591b2ac7c99ea43e7f94f3dfb183019c2fed6e
Commit:        c8591b2ac7c99ea43e7f94f3dfb183019c2fed6e
Parent:        6fc4c99b2fc745b0167520f9395e9e2e39c162e8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 25 11:34:21 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 25 11:55:37 2012 +0200

dev-io: open device read-only to obtain readahead value

There's no need to have the device open RW while obtaining the readahead value.
The RW open used before caused the CHANGE udev event to be generated if the
WATCH udev rule was set for the underlying device (and that is normally the
case both for non-dm and dm devices by default).

This did not cause any problems before since we were not interested in
*underlying* devices. However, with upcoming changes (autoactivation), we're
watching for events on underlying devices marked as PVs and such a spurious
event could cause the autoactivation code to be triggered. So when trying
to deactivate the volume, we could end up with immediate activation just after
that because of the CHANGE event originated in the WATCH udev rule since the
underlying device was open RW during the deactivation process.

Though maybe a better solution would be to completely filter such spurious
events out of the autoactivation process somehow, it's still useful if there
are as least spurious events generated as possible in the system itself.
---
 WHATS_NEW           |    1 +
 lib/device/dev-io.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 90157c8..9479d6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Open device read-only to obtain readahead value.
   Fix lvconvert error path NULL pointer dereference.
   Check for create_instance() fail in pvscan_lvmetad_single().
   Use 64bit math for reserved memory and stack.
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index eecc759..3bb9d65 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -282,7 +282,7 @@ static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 		return 1;
 	}
 
-	if (!dev_open(dev))
+	if (!dev_open_readonly(dev))
 		return_0;
 
 	if (ioctl(dev->fd, BLKRAGET, &read_ahead_long) < 0) {


