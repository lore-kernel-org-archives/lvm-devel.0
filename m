From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Nov 2011 10:59:08 +0100
Subject: [PATCH 6/7] Drop extra stat before open of device
In-Reply-To: <cover.1322213495.git.zkabelac@redhat.com>
References: <cover.1322213495.git.zkabelac@redhat.com>
Message-ID: <931ffcba7ff33d370f53bd3824442b5f992b9e45.1322213495.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use the cached value of stat() and dropping extra call for 'stat()'
before calling 'open()' and expect, that if device has been changed,
it would be catched with the 'fstat()' call that follows the 'open()'
call. If the device has dissappered 'open()' will fail.

This safes one extra 'stat()' call per each device.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-io.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index bf30fe0..950e197 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -454,17 +454,6 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 	else if (!(name = dev_name_confirmed(dev, quiet)))
 		return_0;
 
-	if (!(dev->flags & DEV_REGULAR)) {
-		if (stat(name, &buf) < 0) {
-			log_sys_error("%s: stat failed", name);
-			return 0;
-		}
-		if (buf.st_rdev != dev->dev) {
-			log_error("%s: device changed", name);
-			return 0;
-		}
-	}
-
 #ifdef O_DIRECT_SUPPORT
 	if (direct) {
 		if (!(dev->flags & DEV_O_DIRECT_TESTED))
-- 
1.7.7.3


