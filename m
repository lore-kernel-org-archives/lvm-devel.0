From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Feb 2019 11:23:44 -0500
Subject: master - apply obtain_device_list_from_udev to all libudev usage
Message-ID: <201902051623.x15GNiN9018062@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ebce8dbd2d9afc031e0737f8feed796ec7a8df9
Commit:        3ebce8dbd2d9afc031e0737f8feed796ec7a8df9
Parent:        d19e3727951853093828b072e254e447f7d61c60
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 10:15:40 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 5 10:15:40 2019 -0600

apply obtain_device_list_from_udev to all libudev usage

udev_dev_is_md_component and udev_dev_is_mpath_component
are not used for obtaining the device list, but they still
use libudev for device info.  When there are problems with
udev, these functions can get stuck. So, use the existing
obtain_device_list_from_udev config setting to also control
whether these "is component" functions are used, which gives
us a way to avoid using libudev entirely when it's causing
problems.
---
 lib/device/dev-type.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 9278b51..e9106a9 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1138,6 +1138,9 @@ int udev_dev_is_mpath_component(struct device *dev)
 	const char *value;
 	int ret = 0;
 
+	if (!obtain_device_list_from_udev())
+		return 0;
+
 	if (!(udev_device = _udev_get_dev(dev)))
 		return 0;
 
@@ -1167,6 +1170,9 @@ int udev_dev_is_md_component(struct device *dev)
 	const char *value;
 	int ret = 0;
 
+	if (!obtain_device_list_from_udev())
+		return 0;
+
 	if (!(udev_device = _udev_get_dev(dev)))
 		return 0;
 


