From: Milan Broz <mbroz@redhat.com>
Date: Thu, 12 Aug 2010 16:07:59 +0200
Subject: [PATCH 4/4] Detect LUKS signature in pvcreate
In-Reply-To: <cover.1281621747.git.mbroz@redhat.com>
References: <cover.1281621747.git.mbroz@redhat.com>
Message-ID: <7229a352e9de34559a9fbbf675ade154c0cbb5f7.1281621747.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

One shiny day we should use libblkid here. But now using LUKS is
very common together with LVM and pvcreate destroys LUKS completely.

So for user's convenience, try to detect LUKS signature and allow abort.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/Makefile.in         |    1 +
 lib/device/dev-luks.c   |   43 +++++++++++++++++++++++++++++++++++++++++++
 lib/device/device.h     |    1 +
 lib/metadata/metadata.c |    3 +++
 4 files changed, 48 insertions(+), 0 deletions(-)
 create mode 100644 lib/device/dev-luks.c

diff --git a/lib/Makefile.in b/lib/Makefile.in
index ae81040..1c58bdd 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -47,6 +47,7 @@ SOURCES =\
 	device/dev-io.c \
 	device/dev-md.c \
 	device/dev-swap.c \
+	device/dev-luks.c \
 	device/device.c \
 	display/display.c \
 	error/errseg.c \
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
new file mode 100644
index 0000000..6337992
--- /dev/null
+++ b/lib/device/dev-luks.c
@@ -0,0 +1,43 @@
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
+
+#define LUKS_SIGNATURE "LUKS\xba\xbe"
+#define LUKS_SIGNATURE_SIZE 6
+
+int dev_is_luks(struct device *dev, uint64_t *signature)
+{
+	char buf[LUKS_SIGNATURE_SIZE];
+	int ret = -1;
+
+	if (!dev_open(dev)) {
+		stack;
+		return -1;
+	}
+
+	*signature = 0;
+
+	if (!dev_read(dev, 0, LUKS_SIGNATURE_SIZE, buf))
+		goto_out;
+
+	ret = memcmp(buf, LUKS_SIGNATURE, LUKS_SIGNATURE_SIZE) ? 0 : 1;
+
+out:
+	if (!dev_close(dev))
+		stack;
+
+	return ret;
+}
diff --git a/lib/device/device.h b/lib/device/device.h
index 8bf33e6..5a59950 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -96,6 +96,7 @@ const char *dev_name_confirmed(struct device *dev, int quiet);
 /* Does device contain md superblock?  If so, where? */
 int dev_is_md(struct device *dev, uint64_t *sb);
 int dev_is_swap(struct device *dev, uint64_t *signature);
+int dev_is_luks(struct device *dev, uint64_t *signature);
 unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index db196d6..ed00ffa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1640,6 +1640,9 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	if (!_wipe_sb(dev, "swap signature", name, 10, pp, dev_is_swap))
 		return 0;
 
+	if (!_wipe_sb(dev, "LUKS signature", name, 8, pp, dev_is_luks))
+		return 0;
+
 	if (sigint_caught())
 		return 0;
 
-- 
1.7.1


