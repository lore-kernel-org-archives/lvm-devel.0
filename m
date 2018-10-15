From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:44 -0400
Subject: master - cov: check dev_close_immediate
Message-ID: <201810151555.w9FFtitr020659@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1ff52ca146f58938c07f6c6855bc860453059e6
Commit:        b1ff52ca146f58938c07f6c6855bc860453059e6
Parent:        251366146727aac97af5de2eef855860d14910ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 16:06:35 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: check dev_close_immediate

Function can report log_error() on fail path.
---
 lib/device/dev-cache.c |    4 ++--
 lib/device/dev-io.c    |    6 ++++--
 tools/pvscan.c         |    3 ++-
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 59e00ae..f83ccda 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1302,8 +1302,8 @@ static int _check_for_open_devices(int close_immediate)
 			log_error("Device '%s' has been left open (%d remaining references).",
 				  dev_name(dev), dev->open_count);
 			num_open++;
-			if (close_immediate)
-				dev_close_immediate(dev);
+			if (close_immediate && !dev_close_immediate(dev))
+				stack;
 		}
 	}
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index d4210a5..a3643c4 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -504,7 +504,8 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		/* dev_close_immediate will decrement this */
 		dev->open_count++;
 
-		dev_close_immediate(dev);
+		if (!dev_close_immediate(dev))
+			return_0;
 		// FIXME: dev with DEV_ALLOCED is released
 		// but code is referencing it
 	}
@@ -585,7 +586,8 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 	if (!(dev->flags & DEV_REGULAR) &&
 	    ((fstat(dev->fd, &buf) < 0) || (buf.st_rdev != dev->dev))) {
 		log_error("%s: fstat failed: Has device name changed?", name);
-		dev_close_immediate(dev);
+		if (!dev_close_immediate(dev))
+			stack;
 		return 0;
 	}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index fd75362..da63074 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -284,7 +284,8 @@ static void _online_pvid_file_create(struct device *dev)
 
 	/* We don't care about syncing, these files are not even persistent. */
 
-	close(fd);
+	if (close(fd))
+		log_sys_debug("close", path);
 }
 
 static int _online_pvid_file_exists(const char *pvid)


