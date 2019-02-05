From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Feb 2019 11:23:23 -0500
Subject: 2018-06-01-stable - apply obtain_device_list_from_udev to all libudev usage
Message-ID: <201902051623.x15GNNVk018050@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57cde6063f3073e73542c5f7f59d0269ad9b703b
Commit:        57cde6063f3073e73542c5f7f59d0269ad9b703b
Parent:        d0cb672466437161055ac084a5c1523b0eec1bf5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 10:15:40 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 5 10:20:24 2019 -0600

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
index 33ebb73..e909c0f 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1063,6 +1063,9 @@ int udev_dev_is_mpath_component(struct device *dev)
 	const char *value;
 	int ret = 0;
 
+	if (!obtain_device_list_from_udev())
+		return 0;
+
 	if (!(udev_device = _udev_get_dev(dev)))
 		return 0;
 
@@ -1092,6 +1095,9 @@ int udev_dev_is_md_component(struct device *dev)
 	const char *value;
 	int ret = 0;
 
+	if (!obtain_device_list_from_udev())
+		return 0;
+
 	if (!(udev_device = _udev_get_dev(dev)))
 		return 0;
 


