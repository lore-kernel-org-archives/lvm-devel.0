From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Oct 2017 09:39:40 -0400
Subject: master - devcache: track more udev errors
Message-ID: <201710301339.v9UDdee0015260@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9206fb93dcbc7c07ee7f6c4438f1dbd91c4d73a
Commit:        e9206fb93dcbc7c07ee7f6c4438f1dbd91c4d73a
Parent:        af21263cb39bb850d5bf437fe0371e173b8c0246
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 30 13:16:50 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 30 13:16:50 2017 +0100

devcache: track more udev errors

Add a bit more details for failing udev function.
---
 lib/device/dev-cache.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 83c2b12..dd12da1 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -939,12 +939,20 @@ static int _insert_udev_dir(struct udev *udev, const char *dir)
 	struct udev_device *device;
 	int r = 1;
 
-	if (!(udev_enum = udev_enumerate_new(udev)))
-		goto bad;
+	if (!(udev_enum = udev_enumerate_new(udev))) {
+		log_error("Failed to udev_enumerate_new.");
+		return 0;
+	}
 
-	if (udev_enumerate_add_match_subsystem(udev_enum, "block") ||
-	    udev_enumerate_scan_devices(udev_enum))
-		goto bad;
+	if (udev_enumerate_add_match_subsystem(udev_enum, "block")) {
+		log_error("Failed to udev_enumerate_add_match_subsystem.");
+		goto out;
+	}
+
+	if (udev_enumerate_scan_devices(udev_enum)) {
+		log_error("Failed to udev_enumerate_scan_devices.");
+		goto out;
+	}
 
 	/*
 	 * Report any missing information as "log_very_verbose" only, do not
@@ -981,13 +989,10 @@ static int _insert_udev_dir(struct udev *udev, const char *dir)
 		udev_device_unref(device);
 	}
 
+out:
 	udev_enumerate_unref(udev_enum);
-	return r;
 
-bad:
-	log_error("Failed to enumerate udev device list.");
-	udev_enumerate_unref(udev_enum);
-	return 0;
+	return r;
 }
 
 static void _insert_dirs(struct dm_list *dirs)


