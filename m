From: Daniel Golle <daniel@makrotopia.org>
Date: Fri, 20 May 2016 06:38:10 +0200
Subject: [PATCH] device: include goto label also for O_NOATIME
Message-ID: <20160520043805.GA19157@makrotopia.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

commit b5314c2a6ae5fe4f802e82a4f31cf2fad398ded9
 device:  Retry open without O_NOATIME if it fails.

makes use of goto lable 'opened:' but that might not be defined, e.g.
on standard C libraries without O_DIRECT_SUPPORT. Make sure it is
defined also if only O_NOATIME is supported as compiling obviously
fails otherwise:
 device/dev-io.c:508:5: error: label 'opened' used but not defined
---
 lib/device/dev-io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index a9a2374..4d71967 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -529,7 +529,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		return 0;
 	}
 
-#ifdef O_DIRECT_SUPPORT
+#if defined(O_DIRECT_SUPPORT) || defined(O_NOATIME)
       opened:
 	if (direct)
 		dev->flags |= DEV_O_DIRECT_TESTED;
-- 
2.8.2


