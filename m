From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:43 +0000 (GMT)
Subject: main - cov: mask uninitialized value
Message-ID: <20210310003643.653D33858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bee9b5c1d8d8f54c3ffe3c96abd2ce28cd2b5558
Commit:        bee9b5c1d8d8f54c3ffe3c96abd2ce28cd2b5558
Parent:        74936f53f7123c092d2ba6b9b7883db47bf0c61c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 15:58:48 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:34:27 2021 +0100

cov: mask uninitialized value

Coverity doesn't track ioctl() too well, so let's just make it quiet.
---
 device_mapper/libdm-common.c | 2 +-
 lib/device/dev-dasd.c        | 2 +-
 lib/device/dev-io.c          | 2 +-
 lib/device/dev-type.c        | 2 +-
 libdm/libdm-common.c         | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index a2304b603..c0dde2071 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -1224,7 +1224,7 @@ int get_dev_node_read_ahead(const char *dev_name, uint32_t major, uint32_t minor
 	int len;
 	int r = 1;
 	int fd;
-	long read_ahead_long;
+	long read_ahead_long = 0;
 
 	/*
 	 * If we know the device number, use sysfs if we can.
diff --git a/lib/device/dev-dasd.c b/lib/device/dev-dasd.c
index dc11030d7..0448e1f78 100644
--- a/lib/device/dev-dasd.c
+++ b/lib/device/dev-dasd.c
@@ -81,7 +81,7 @@ typedef struct dasd_information2_t {
 int dasd_is_cdl_formatted(struct device *dev)
 {
 	int ret = 0;
-	dasd_information2_t dasd_info2;
+	dasd_information2_t dasd_info2 = { 0 };
 
 	if (!dev_open_readonly(dev))
 		return_0;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 9b007dcaa..17993d82c 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -124,7 +124,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 
 static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 {
-	long read_ahead_long;
+	long read_ahead_long = 0;
 
 	if (dev->read_ahead != -1) {
 		*read_ahead = (uint32_t) dev->read_ahead;
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 40c2a748e..7cbb7fbed 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -891,7 +891,7 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 			   int (*signature_detection_fn)(struct device *dev, uint64_t *offset_found, int full))
 {
 	int wipe;
-	uint64_t offset_found;
+	uint64_t offset_found = 0;
 
 	wipe = signature_detection_fn(dev, &offset_found, 1);
 	if (wipe == -1) {
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index f2ea64905..1f3fe1642 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1222,7 +1222,7 @@ int get_dev_node_read_ahead(const char *dev_name, uint32_t major, uint32_t minor
 	int len;
 	int r = 1;
 	int fd;
-	long read_ahead_long;
+	long read_ahead_long = 0;
 
 	/*
 	 * If we know the device number, use sysfs if we can.


