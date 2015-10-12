From: Lidong Zhong <lzhong@suse.com>
Date: Mon, 12 Oct 2015 15:09:11 +0800
Subject: [PATCH] pvcreate: don't support unpartitioned DASD devices with CDL formatted
Message-ID: <1444633751-10796-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The former patch(dab3ebce4c7) is a little bit strict. For example, it is
OK to create PV on unpartitioned DASD devices with LDL formatted. So
after lvm version containing the patch, LVs created on those devices
could not be found.

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
 lib/Makefile.in       |  1 +
 lib/device/dev-dasd.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/device/dev-type.c |  2 +-
 lib/device/dev-type.h |  1 +
 4 files changed, 78 insertions(+), 1 deletion(-)
 create mode 100644 lib/device/dev-dasd.c

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 3e0e6f8..00014c2 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -62,6 +62,7 @@ SOURCES =\
 	device/dev-swap.c \
 	device/dev-type.c \
 	device/dev-luks.c \
+	device/dev-dasd.c \
 	display/display.c \
 	error/errseg.c \
 	unknown/unknown.c \
diff --git a/lib/device/dev-dasd.c b/lib/device/dev-dasd.c
new file mode 100644
index 0000000..8f547b3
--- /dev/null
+++ b/lib/device/dev-dasd.c
@@ -0,0 +1,75 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "metadata.h"
+#include "dev-type.h"
+#include <sys/ioctl.h>
+
+
+typedef struct dasd_information_t {
+	unsigned int devno;         /* S/390 devno */
+	unsigned int real_devno;    /* for aliases */
+	unsigned int schid;         /* S/390 subchannel identifier */
+	unsigned int cu_type  : 16; /* from SenseID */
+	unsigned int cu_model :  8; /* from SenseID */
+	unsigned int dev_type : 16; /* from SenseID */
+	unsigned int dev_model : 8; /* from SenseID */
+	unsigned int open_count;
+	unsigned int req_queue_len;
+	unsigned int chanq_len;     /* length of chanq */
+	char type[4];               /* from discipline.name, 'none' for unknown */
+	unsigned int status;        /* current device level */
+	unsigned int label_block;   /* where to find the VOLSER */
+	unsigned int FBA_layout;    /* fixed block size (like AIXVOL) */
+	unsigned int characteristics_size;
+	unsigned int confdata_size;
+	unsigned char characteristics[64];/*from read_device_characteristics */
+	unsigned char configuration_data[256];/*from read_configuration_data */
+	unsigned int format;          /* format info like formatted/cdl/ldl/... */
+	unsigned int features;        /* dasd features like 'ro',...            */
+	unsigned int reserved0;       /* reserved for further use ,...          */
+	unsigned int reserved1;       /* reserved for further use ,...          */
+	unsigned int reserved2;       /* reserved for further use ,...          */
+	unsigned int reserved3;       /* reserved for further use ,...          */
+	unsigned int reserved4;       /* reserved for further use ,...          */
+	unsigned int reserved5;       /* reserved for further use ,...          */
+	unsigned int reserved6;       /* reserved for further use ,...          */
+	unsigned int reserved7;       /* reserved for further use ,...          */
+} dasd_information_t;
+
+#define DASD_FORMAT_CDL 2
+#define BIODASDINFO2  _IOR('D',3,dasd_information_t)
+
+int dasd_is_cdl_formatted(struct device *dev)
+{
+	int ret = 0;
+	dasd_information_t dasd_info;
+
+	if (!dev_open_readonly(dev)) {
+		stack;
+		return ret;
+	}
+
+	if (ioctl(dev->fd, BIODASDINFO2, &dasd_info) != 0)
+		goto_out;
+
+	if (dasd_info.format == DASD_FORMAT_CDL)
+		ret = 1;
+
+out:
+	if (!dev_close(dev))
+		stack;
+	return ret;
+}
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 25f11d1..75d91bb 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -363,7 +363,7 @@ static int _native_dev_is_partitioned(struct dev_types *dt, struct device *dev)
 		return 0;
 
 	/* Unpartitioned DASD devices are not supported. */
-	if (MAJOR(dev->dev) == dt->dasd_major)
+	if ((MAJOR(dev->dev) == dt->dasd_major) && dasd_is_cdl_formatted(dev))
 		return 1;
 
 	if (!dev_open_readonly_quiet(dev)) {
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 2a49b4b..f1d52ca 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -59,6 +59,7 @@ int major_is_scsi_device(struct dev_types *dt, int major);
 int dev_is_md(struct device *dev, uint64_t *sb);
 int dev_is_swap(struct device *dev, uint64_t *signature);
 int dev_is_luks(struct device *dev, uint64_t *signature);
+int dasd_is_cdl_formatted(struct device *dev);
 
 /* Signature wiping. */
 #define TYPE_LVM1_MEMBER	0x001
-- 
1.8.1.4


