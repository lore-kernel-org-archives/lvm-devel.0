From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Dec 2018 07:27:15 -0500
Subject: master - dmeventd: resolve compilation of vdo status parsing
Message-ID: <201812201227.wBKCRFm0030641@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9785e40b8d52fd87d7c451ed838f450aee41ba8d
Commit:        9785e40b8d52fd87d7c451ed838f450aee41ba8d
Parent:        f05104af76e26f0757df1500540e767dd889ae71
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 19 12:54:14 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 20 13:26:55 2018 +0100

dmeventd: resolve compilation of vdo status parsing

A bit of chicken & egg problem - dmeventd needs to use old libdm library.
VDO is only part of new device_mapper internal library.

So include directly source file for parsing status - this fixes usability
problem of VDO plugin introduced with previous Makefile reshaping
patchset.

NOTE: source file needs to be keep then compilable in both environments.

Also add missing copyright header.
---
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c |    4 +++-
 device_mapper/vdo/status.c                  |   22 ++++++++++++++++++++--
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index b5e2766..d5156cd 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -15,7 +15,9 @@
 #include "lib/misc/lib.h"
 #include "daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
-#include "device_mapper/vdo/target.h"
+
+/* Use parser from new device_mapper library */
+#include "device_mapper/vdo/status.c"
 
 #include <sys/wait.h>
 #include <stdarg.h>
diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index 40e69ba..a34029d 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -1,8 +1,26 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+/* Note: this object is also used by VDO dmeventd plugin for parsing status */
+/* File could be included by VDO plugin and can use original libdm library */
+#ifndef LIB_DMEVENT_H
 #include "configure.h"
-#include "target.h"
-
 // For DM_ARRAY_SIZE!
 #include "device_mapper/all.h"
+#endif
+
+#include "device_mapper/vdo/target.h"
 #include "base/memory/zalloc.h"
 
 #include <ctype.h>


