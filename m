From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:09 +0000 (GMT)
Subject: main - libdm: correct version check
Message-ID: <20211220151409.77F5A3858005@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39a121ddbcf83314c5a75e23671acbc6600292ce
Commit:        39a121ddbcf83314c5a75e23671acbc6600292ce
Parent:        47ac2659d5f8544dcd53aeef13a42b3256f2fd6f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 8 10:56:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

libdm: correct version check

If there ever would be API version 5,
these check would give incorrect results.
---
 device_mapper/ioctl/libdm-iface.c | 6 ++----
 libdm/ioctl/libdm-iface.c         | 6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 533bb9eea..925f18c6b 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -616,8 +616,7 @@ int dm_check_version(void)
 int dm_cookie_supported(void)
 {
 	return (dm_check_version() &&
-		_dm_version >= 4 &&
-		_dm_version_minor >= 15);
+		((_dm_version == 4) ? _dm_version_minor >= 15 : _dm_version > 4));
 }
 
 static int _dm_inactive_supported(void)
@@ -1441,8 +1440,7 @@ static int _udev_complete(struct dm_task *dmt)
 static int _check_uevent_generated(struct dm_ioctl *dmi)
 {
 	if (!dm_check_version() ||
-	    _dm_version < 4 ||
-	    _dm_version_minor < 17)
+	    ((_dm_version == 4) ? _dm_version_minor < 17 : _dm_version < 4))
 		/* can't check, assume uevent is generated */
 		return 1;
 
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 28589a15c..a3a1bdc66 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -609,8 +609,7 @@ int dm_check_version(void)
 int dm_cookie_supported(void)
 {
 	return (dm_check_version() &&
-		_dm_version >= 4 &&
-		_dm_version_minor >= 15);
+		((_dm_version == 4) ? _dm_version_minor >= 15 : _dm_version > 4));
 }
 
 static int _dm_inactive_supported(void)
@@ -1436,8 +1435,7 @@ static int _udev_complete(struct dm_task *dmt)
 static int _check_uevent_generated(struct dm_ioctl *dmi)
 {
 	if (!dm_check_version() ||
-	    _dm_version < 4 ||
-	    _dm_version_minor < 17)
+	    ((_dm_version == 4) ? _dm_version_minor < 17 : _dm_version < 4))
 		/* can't check, assume uevent is generated */
 		return 1;
 


