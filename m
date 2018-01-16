From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:06 -0500
Subject: master - device: Reorder device.h before change.
Message-ID: <201801160317.w0G3H6HS025339@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61d3296f2aae134a9215a9c9c2f3146a75fddc19
Commit:        61d3296f2aae134a9215a9c9c2f3146a75fddc19
Parent:        da37cbd24fc0073f3f00a3b7aac7807d2185b829
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 15 19:24:01 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 15 19:24:01 2018 +0000

device: Reorder device.h before change.

---
 lib/device/device.h |   56 ++++++++++++++++++++++++--------------------------
 1 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/lib/device/device.h b/lib/device/device.h
index 926d24a..6280138 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -56,6 +56,28 @@ struct dev_ext {
 	void *handle;
 };
 
+/*
+ * All I/O is annotated with the reason it is performed.
+ */
+typedef enum dev_io_reason {
+	DEV_IO_SIGNATURES = 0,	/* Scanning device signatures */
+	DEV_IO_LABEL,		/* LVM PV disk label */
+	DEV_IO_MDA_HEADER,	/* Text format metadata area header */
+	DEV_IO_MDA_CONTENT,	/* Text format metadata area content */
+	DEV_IO_MDA_EXTRA_HEADER,	/* Header of any extra metadata areas on device */
+	DEV_IO_MDA_EXTRA_CONTENT,	/* Content of any extra metadata areas on device */
+	DEV_IO_FMT1,		/* Original LVM1 metadata format */
+	DEV_IO_POOL,		/* Pool metadata format */
+	DEV_IO_LV,		/* Content written to an LV */
+	DEV_IO_LOG		/* Logging messages */
+} dev_io_reason_t;
+
+/*
+ * Is this I/O for a device's extra metadata area?
+ */
+#define EXTRA_IO(reason) ((reason) == DEV_IO_MDA_EXTRA_HEADER || (reason) == DEV_IO_MDA_EXTRA_CONTENT)
+#define DEV_DEVBUF(dev, reason) (EXTRA_IO((reason)) ? &(dev)->last_extra_devbuf : &(dev)->last_devbuf)
+
 struct device_area {
 	struct device *dev;
 	uint64_t start;		/* Bytes */
@@ -63,13 +85,11 @@ struct device_area {
 };
 
 struct device_buffer {
-	const void *data;             /* Location of start of requested data (inside buf) */
-
-	/* Private */
-	void *malloc_address;   /* Start of allocated memory */
-	void *buf;              /* Aligned buffer that contains data within it */
-	struct device_area where;       /* Location of buf */
-	unsigned write:1;       /* 1 if write; 0 if read */
+	const void *data;	/* Location of start of requested data (inside buf) */
+	void *malloc_address;	/* Start of allocated memory */
+	void *buf;		/* Aligned buffer that contains data within it */
+	struct device_area where;	/* Location of buf */
+	unsigned write:1;	/* 1 if write; 0 if read */
 };
 
 /*
@@ -104,28 +124,6 @@ struct device {
 	char _padding[7];
 };
 
-/*
- * All I/O is annotated with the reason it is performed.
- */
-typedef enum dev_io_reason {
-	DEV_IO_SIGNATURES = 0,	/* Scanning device signatures */
-	DEV_IO_LABEL,		/* LVM PV disk label */
-	DEV_IO_MDA_HEADER,	/* Text format metadata area header */
-	DEV_IO_MDA_CONTENT,	/* Text format metadata area content */
-	DEV_IO_MDA_EXTRA_HEADER,	/* Header of any extra metadata areas on device */
-	DEV_IO_MDA_EXTRA_CONTENT,	/* Content of any extra metadata areas on device */
-	DEV_IO_FMT1,		/* Original LVM1 metadata format */
-	DEV_IO_POOL,		/* Pool metadata format */
-	DEV_IO_LV,		/* Content written to an LV */
-	DEV_IO_LOG		/* Logging messages */
-} dev_io_reason_t;
-
-/*
- * Is this I/O for a device's extra metadata area?
- */
-#define EXTRA_IO(reason) ((reason) == DEV_IO_MDA_EXTRA_HEADER || (reason) == DEV_IO_MDA_EXTRA_CONTENT)
-#define DEV_DEVBUF(dev, reason) (EXTRA_IO((reason)) ? &(dev)->last_extra_devbuf : &(dev)->last_devbuf)
-
 struct device_list {
 	struct dm_list list;
 	struct device *dev;


