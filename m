From: Bastian Blank <bastian@waldi.eu.org>
Date: Fri, 30 Oct 2009 15:51:25 +0100
Subject: [PATCH] udev: move notify rule
Message-ID: <20091030145125.GA21583@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move notify rule into the first rules file. The RUN commands is executed
after everything is finished, so it makes no difference if it is set
early or late.

diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 9c2e256..211011c 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -26,6 +26,12 @@ TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
 # kernels >= 2.6.31 only.
 ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
 
+# These rules are responsible for sending a notification to a process
+# waiting for completion of udev rules. The process is identified by
+# a cookie value sent within "change" and "remove" events (the cookie
+# value is set before by that process for every action requested).
+ACTION=="change|remove", ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
+
 # Normally, we would test for DM_UDEV_DISABLE_DM_RULES_FLAG here and skip
 # the rules if set. However, we need to set DM_* environment variables
 # for now to properly filter out inappropriate events. This dependency
diff --git a/udev/95-dm-notify.rules b/udev/95-dm-notify.rules
deleted file mode 100644
index c6bf23b..0000000
--- a/udev/95-dm-notify.rules
+++ /dev/null
@@ -1,18 +0,0 @@
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-
-# Udev rules for device-mapper devices.
-#
-# These rules are responsible for sending a notification to a process
-# waiting for completion of udev rules. The process is identified by
-# a cookie value sent within "change" and "remove" events (the cookie
-# value is set before by that process for every action requested).
-
-SUBSYSTEM!="block", GOTO="dm_end"
-KERNEL!="dm-[0-9]*", GOTO="dm_end"
-ACTION!="change|remove", GOTO="dm_end"
-
-ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
-
-LABEL="dm_end"
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 0a0050a..06d5ecc 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -16,7 +16,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
+DM_RULES=10-dm.rules 13-dm-disk.rules
 LVM_RULES=11-dm-lvm.rules
 DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk '{print $$3}')
-- 
One does not thank logic.
		-- Sarek, "Journey to Babel", stardate 3842.4


