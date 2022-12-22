From: Sam James <sam@gentoo.org>
Date: Thu, 22 Dec 2022 03:14:34 +0000
Subject: [PATCH] tools: Add missing include for LOCK_EX
Message-ID: <20221222031434.2081509-1-sam@gentoo.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Jory Pratt <anarchy@gentoo.org>

Fixes musl build.

Bug: https://bugs.gentoo.org/887259
Signed-off-by: Jory Pratt <anarchy@gentoo.org>
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
2.39.0

