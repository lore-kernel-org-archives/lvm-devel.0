From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Mar 2016 12:26:18 +0000 (UTC)
Subject: master - device: add DEV_OPEN_FAILURE flag
Message-ID: <20160321122618.0696760D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65d9f742f8e45caaa530e1eaf9f18bfd689af6f3
Commit:        65d9f742f8e45caaa530e1eaf9f18bfd689af6f3
Parent:        e58d24293f10b6e29825113cadab8aa70099a128
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 17 13:45:14 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 21 11:06:05 2016 +0100

device: add DEV_OPEN_FAILURE flag

DEV_OPEN_FAILURE flag is set if the most recent "open" for a device
failed and it's unset if any subsequent "open" succeeds.
---
 lib/device/dev-io.c |    3 +++
 lib/device/device.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index f8b24bf..9bf6d2e 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -513,6 +513,8 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 			log_sys_debug("open", name);
 		else
 			log_sys_error("open", name);
+
+		dev->flags |= DEV_OPEN_FAILURE;
 		return 0;
 	}
 
@@ -556,6 +558,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		       dev->flags & DEV_OPENED_EXCL ? " O_EXCL" : "",
 		       dev->flags & DEV_O_DIRECT ? " O_DIRECT" : "");
 
+	dev->flags &= ~DEV_OPEN_FAILURE;
 	return 1;
 }
 
diff --git a/lib/device/device.h b/lib/device/device.h
index 6b01fb6..fc5a5b9 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -27,6 +27,7 @@
 #define DEV_OPENED_EXCL		0x00000010	/* Opened EXCL */
 #define DEV_O_DIRECT		0x00000020	/* Use O_DIRECT */
 #define DEV_O_DIRECT_TESTED	0x00000040	/* DEV_O_DIRECT is reliable */
+#define DEV_OPEN_FAILURE	0x00000080	/* Has last open failed? */
 
 /*
  * Support for external device info.


