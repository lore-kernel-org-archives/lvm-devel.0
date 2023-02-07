From: David Seifert <soap@gentoo.org>
Date: Tue,  7 Feb 2023 14:27:12 +0100
Subject: [PATCH] vgimportdevices: LOCK_EX requires <sys/file.h> include
Message-ID: <20230207132712.32616-1-soap@gentoo.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Jory Pratt <anarchy@gentoo.org>

https://linux.die.net/man/2/flock

Bug: https://bugs.gentoo.org/887259
---
 tools/vgimportdevices.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index ab359d31c..d8260c731 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -15,6 +15,7 @@
 #include "tools.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/device/device_id.h"
+#include <sys/file.h>
 
 struct vgimportdevices_params {
 	uint32_t added_devices;
-- 
2.39.1

