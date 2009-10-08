From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:14 +0200
Subject: [PATCH 07/11] debian: workaround for broken kernel headers
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <5afd58961d2c413baaa3d970daa59999c0cc3daf.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

this patch might be debian specific and needs more investigation.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 5ba63ce... a8edf55... M	libdm/ioctl/libdm-compat.h
:100644 100644 5fcda74... ec990d7... M	libdm/misc/kdev_t.h
 libdm/ioctl/libdm-compat.h |    5 +++--
 libdm/misc/kdev_t.h        |    4 ++++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-compat.h b/libdm/ioctl/libdm-compat.h
index 5ba63ce..a8edf55 100644
--- a/libdm/ioctl/libdm-compat.h
+++ b/libdm/ioctl/libdm-compat.h
@@ -19,6 +19,7 @@
 #include "kdev_t.h"
 #include "dm-ioctl.h"
 #include <inttypes.h>
+#include <linux/types.h>
 #include <sys/ioctl.h>
 
 struct dm_task;
@@ -40,7 +41,7 @@ struct dm_ioctl_v1 {
 	int32_t open_count;	/* out */
 	uint32_t flags;		/* in/out */
 
-	__kernel_dev_t dev;	/* in/out */
+	devmapper_kernel_dev_t dev;	/* in/out */
 
 	char name[DM_NAME_LEN];	/* device name */
 	char uuid[DM_UUID_LEN];	/* unique identifier for
@@ -60,7 +61,7 @@ struct dm_target_spec_v1 {
 struct dm_target_deps_v1 {
 	uint32_t count;
 
-	__kernel_dev_t dev[0];	/* out */
+	devmapper_kernel_dev_t dev[0];	/* out */
 };
 
 enum {
diff --git a/libdm/misc/kdev_t.h b/libdm/misc/kdev_t.h
index 5fcda74..ec990d7 100644
--- a/libdm/misc/kdev_t.h
+++ b/libdm/misc/kdev_t.h
@@ -15,8 +15,12 @@
 #ifndef _LIBDM_KDEV_H
 #define _LIBDM_KDEV_H
 
+#include <linux/types.h>
+
 #define MAJOR(dev)      ((dev & 0xfff00) >> 8)
 #define MINOR(dev)      ((dev & 0xff) | ((dev >> 12) & 0xfff00))
 #define MKDEV(ma,mi)    ((mi & 0xff) | (ma << 8) | ((mi & ~0xff) << 12))
 
+typedef __u32 devmapper_kernel_dev_t;
+
 #endif
-- 
1.5.4.3


