From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 27 Oct 2015 15:30:38 +0000 (UTC)
Subject: master - device: Tidy DASD CDL format detection code.
Message-ID: <20151027153038.27D6861010@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65ec00ce202411f6e6f91955ab9422d44bb86a9b
Commit:        65ec00ce202411f6e6f91955ab9422d44bb86a9b
Parent:        6e1e0e881368be6337599dcf7f627f785ebf415c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Oct 27 15:27:52 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 27 15:27:52 2015 +0000

device: Tidy DASD CDL format detection code.

---
 lib/device/dev-dasd.c |   85 +++++++++++++++++++++++++++++++++++--------------
 1 files changed, 61 insertions(+), 24 deletions(-)

diff --git a/lib/device/dev-dasd.c b/lib/device/dev-dasd.c
index 28156ca..220293e 100644
--- a/lib/device/dev-dasd.c
+++ b/lib/device/dev-dasd.c
@@ -17,7 +17,28 @@
 #include "dev-type.h"
 #include <sys/ioctl.h>
 
-typedef struct dasd_information_t {
+#ifdef __linux__
+
+/*
+ * Interface taken from kernel header arch/s390/include/uapi/asm/dasd.h
+ */
+
+/* 
+ * Author(s)......: Holger Smolinski <Holger.Smolinski@de.ibm.com>
+ * Copyright IBM Corp. 1999, 2000
+ * EMC Symmetrix ioctl Copyright EMC Corporation, 2008
+ * Author.........: Nigel Hislop <hislop_nigel@emc.com>
+ */
+
+#define DASD_IOCTL_LETTER 'D'
+#define DASD_API_VERSION 6
+
+/* 
+ * struct dasd_information2_t
+ * represents any data about the device, which is visible to userspace.
+ *  including foramt and featueres.
+ */
+typedef struct dasd_information2_t {
 	unsigned int devno;		/* S/390 devno */
 	unsigned int real_devno;	/* for aliases */
 	unsigned int schid;		/* S/390 subchannel identifier */
@@ -34,41 +55,57 @@ typedef struct dasd_information_t {
 	unsigned int FBA_layout;	/* fixed block size (like AIXVOL) */
 	unsigned int characteristics_size;
 	unsigned int confdata_size;
-	unsigned char characteristics[64];/*from read_device_characteristics */
-	unsigned char configuration_data[256];/*from read_configuration_data */
+	char characteristics[64];	/* from read_device_characteristics */
+	char configuration_data[256];	/* from read_configuration_data */
 	unsigned int format;		/* format info like formatted/cdl/ldl/... */
-	unsigned int features;		/* dasd features like 'ro',...            */
-	unsigned int reserved0;		/* reserved for further use ,...          */
-	unsigned int reserved1;		/* reserved for further use ,...          */
-	unsigned int reserved2;		/* reserved for further use ,...          */
-	unsigned int reserved3;		/* reserved for further use ,...          */
-	unsigned int reserved4;		/* reserved for further use ,...          */
-	unsigned int reserved5;		/* reserved for further use ,...          */
-	unsigned int reserved6;		/* reserved for further use ,...          */
-	unsigned int reserved7;		/* reserved for further use ,...          */
-} dasd_information_t;
-
-#define DASD_FORMAT_CDL 2
-#define BIODASDINFO2  _IOR('D', 3, dasd_information_t)
+	unsigned int features;		/* dasd features like 'ro',... */
+	unsigned int reserved0;		/* reserved for further use ,... */
+	unsigned int reserved1;		/* reserved for further use ,... */
+	unsigned int reserved2;		/* reserved for further use ,... */
+	unsigned int reserved3;		/* reserved for further use ,... */
+	unsigned int reserved4;		/* reserved for further use ,... */
+	unsigned int reserved5;		/* reserved for further use ,... */
+	unsigned int reserved6;		/* reserved for further use ,... */
+	unsigned int reserved7;		/* reserved for further use ,... */
+} dasd_information2_t;
+
+#define DASD_FORMAT_CDL  2
+
+/* Get information on a dasd device (enhanced) */
+#define BIODASDINFO2   _IOR(DASD_IOCTL_LETTER,3,dasd_information2_t)
+
+/*
+ * End of included interface.
+ */
 
 int dasd_is_cdl_formatted(struct device *dev)
 {
 	int ret = 0;
-	dasd_information_t dasd_info;
+	dasd_information2_t dasd_info2;
 
-	if (!dev_open_readonly(dev)) {
-		stack;
-		return ret;
-	}
+	if (!dev_open_readonly(dev))
+		return_0;
 
-	if (ioctl(dev->fd, BIODASDINFO2, &dasd_info) != 0)
-		goto_out;
+	if (ioctl(dev->fd, BIODASDINFO2, &dasd_info2)) {
+		log_sys_error("ioctl BIODASDINFO2", dev_name(dev));
+		goto out;
+	}
 
-	if (dasd_info.format == DASD_FORMAT_CDL)
+	if (dasd_info2.format == DASD_FORMAT_CDL)
 		ret = 1;
+
 out:
 	if (!dev_close(dev))
 		stack;
 
 	return ret;
 }
+
+#else
+
+int dasd_is_cdl_formatted(struct device *dev)
+{
+	return 0;
+}
+
+#endif


