From: Jim Meyering <jim@meyering.net>
Date: Fri, 07 Sep 2007 12:36:04 +0200
Subject: dev-io.c: give a better diagnostic upon failed stat
Message-ID: <87y7fi3gq3.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The main change here is to report strerror(errno) upon stat failure:
i.e., the s/log_error/log_sys_error/ part.  Also made the "device changed"
diagnostic more definite.  Ok to commit?

    Use log_sys_error after failed stat to report strerror(errno).
    Use a slightly different diagnostic to report mismatched device number.

---
 lib/device/dev-io.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 9406903..54ae88e 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -359,10 +359,15 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		return 0;
 	}

-	if (!(dev->flags & DEV_REGULAR) &&
-	    ((stat(name, &buf) < 0) || (buf.st_rdev != dev->dev))) {
-		log_error("%s: stat failed: Has device name changed?", name);
-		return 0;
+	if (!(dev->flags & DEV_REGULAR)) {
+		if (stat(name, &buf) < 0) {
+			log_sys_error("%s: stat failed", name);
+			return 0;
+		}
+		if (buf.st_rdev != dev->dev) {
+			log_error("%s: device changed", name);
+			return 0;
+		}
 	}

 #ifdef O_DIRECT_SUPPORT


