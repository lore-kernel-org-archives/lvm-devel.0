From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:43:57 +0000 (GMT)
Subject: main - label: avoid rescaning unusable DM devices
Message-ID: <20210210144357.0D118385DC33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a3835861774f4758e0de2a4b462eb51b91a3f09b
Commit:        a3835861774f4758e0de2a4b462eb51b91a3f09b
Parent:        f90082ce8f218781ff3b9361e748dbff0ff0e2e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 00:43:40 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

label: avoid rescaning unusable DM devices

---
 lib/label/label.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/lib/label/label.c b/lib/label/label.c
index 1e777d7c2..030d2c578 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -707,6 +707,19 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		if (!rem_prefetches)
 			break;
 
+		/* FIXME: figure better solution to avoid opening DM we shouldn't open */
+		if (dm_is_dm_major(MAJOR(devl->dev->dev)) &&
+		    !device_is_usable(devl->dev, (struct dev_usable_check_params) {
+					.check_blocked = 1,
+					.check_suspended = ignore_suspended_devices(),
+					.check_reserved = 1,
+					.check_error_target = 1,
+				      })) {
+			log_debug_devs("Scan skips unusuable DM device %s.", dev_name(devl->dev));
+			dm_list_del(&devl->list);
+			continue;
+		}
+
 		if (!_in_bcache(devl->dev)) {
 			if (!_scan_dev_open(devl->dev)) {
 				log_debug_devs("Scan failed to open %s.", dev_name(devl->dev));


