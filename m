From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Aug 2010 23:08:19 -0000
Subject: LVM2 ./WHATS_NEW lib/Makefile.in lib/device/de ...
Message-ID: <20100819230819.27246.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-19 23:08:18

Modified files:
	.              : WHATS_NEW 
	lib            : Makefile.in 
	lib/device     : device.h 
	lib/metadata   : metadata.c 
Added files:
	lib/device     : dev-luks.c 

Log message:
	Detect LUKS signature in pvcreate
	
	One shiny day we should use libblkid here. But now using LUKS is
	very common together with LVM and pvcreate destroys LUKS completely.
	
	So for user's convenience, try to detect LUKS signature and allow abort.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1715&r2=1.1716
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-luks.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.392&r2=1.393

--- LVM2/WHATS_NEW	2010/08/19 23:05:45	1.1715
+++ LVM2/WHATS_NEW	2010/08/19 23:08:18	1.1716
@@ -3,6 +3,7 @@
   Simplify MD/swap signature detection in pvcreate and allow aborting.
   Remove assumption that --yes must be used only in --force mode.
   Fix file descriptor leak in swap signature detection error path.
+  Detect and allow abort in pvcreate if LUKS signature is detected.
 
 Version 2.02.73 - 18th August 2010
 ==================================
--- LVM2/lib/Makefile.in	2010/05/21 12:36:30	1.103
+++ LVM2/lib/Makefile.in	2010/08/19 23:08:18	1.104
@@ -47,6 +47,7 @@
 	device/dev-io.c \
 	device/dev-md.c \
 	device/dev-swap.c \
+	device/dev-luks.c \
 	device/device.c \
 	display/display.c \
 	error/errseg.c \
/cvs/lvm2/LVM2/lib/device/dev-luks.c,v  -->  standard output
revision 1.1
--- LVM2/lib/device/dev-luks.c
+++ -	2010-08-19 23:08:19.175941000 +0000
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
--- LVM2/lib/device/device.h	2010/08/11 12:14:24	1.44
+++ LVM2/lib/device/device.h	2010/08/19 23:08:18	1.45
@@ -96,6 +96,7 @@
 /* Does device contain md superblock?  If so, where? */
 int dev_is_md(struct device *dev, uint64_t *sb);
 int dev_is_swap(struct device *dev, uint64_t *signature);
+int dev_is_luks(struct device *dev, uint64_t *signature);
 unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
--- LVM2/lib/metadata/metadata.c	2010/08/19 23:03:35	1.392
+++ LVM2/lib/metadata/metadata.c	2010/08/19 23:08:18	1.393
@@ -1640,6 +1640,9 @@
 	if (!_wipe_sb(dev, "swap signature", name, 10, pp, dev_is_swap))
 		return 0;
 
+	if (!_wipe_sb(dev, "LUKS signature", name, 8, pp, dev_is_luks))
+		return 0;
+
 	if (sigint_caught())
 		return 0;
 


