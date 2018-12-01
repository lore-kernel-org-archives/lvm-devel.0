From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:07:51 -0500
Subject: master - device_mapper: move internal header to front
Message-ID: <201812010007.wB107pet031179@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38c7ba315dd4aa2c87a777225b3f3ca333ebe350
Commit:        38c7ba315dd4aa2c87a777225b3f3ca333ebe350
Parent:        65eb29503b7cfe0f509c5b4d6146dd7961d1f8ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 1 00:43:53 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:04:27 2018 +0100

device_mapper: move internal header to front

---
 device_mapper/ioctl/libdm-iface.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index eb6e9db..f86d3b3 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -15,9 +15,11 @@
 
 #include "base/memory/zalloc.h"
 #include "device_mapper/misc/dmlib.h"
+#include "device_mapper/misc/dm-ioctl.h"
 #include "device_mapper/ioctl/libdm-targets.h"
 #include "device_mapper/libdm-common.h"
 
+#include <stdio.h>  /* getline() */
 #include <stddef.h>
 #include <fcntl.h>
 #include <dirent.h>
@@ -35,8 +37,6 @@
 #  define MKDEV(x,y) makedev(((dev_t)x),((dev_t)y))
 #endif
 
-#include "device_mapper/misc/dm-ioctl.h"
-
 /*
  * Ensure build compatibility.  
  * The hard-coded versions here are the highest present 


