From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 21 Jul 2015 08:01:49 +0000 (UTC)
Subject: master - wiping: ignore errors during detection if use_blkid_wiping=1 and --force is used
Message-ID: <20150721080149.7B6EC60F86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a7c2539c63f72d6c50df54f53271e567fa948ee
Commit:        2a7c2539c63f72d6c50df54f53271e567fa948ee
Parent:        500fd8b9bfc6f15d2417c829bce33ea4768261b8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 21 09:54:20 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 21 09:54:20 2015 +0200

wiping: ignore errors during detection if use_blkid_wiping=1 and --force is used

libblkid may return the list of signatures found, but it may not
provide offset and size for each signature detected. This may
happen in case signatures are mixed up or there are more, possibly
overlapping, signatures found.

Make lvm commands pass if such situation happens and we're using
--force (or any stronger force method).

For example:

$ pvcreate /dev/sda1
  Failed to get offset of the xfs_external_log signature on /dev/sda1.
  1 existing signature left on the device.
  Aborting pvcreate on /dev/sda1.

$ pvcreate --force /dev/sda1
  Failed to get offset of the xfs_external_log signature on /dev/sda1.
  Physical volume "/dev/sda1" successfully created
---
 WHATS_NEW             |    1 +
 lib/device/dev-type.c |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3cd9111..22a0233 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Ignore errors during detection if use_blkid_wiping=1 and --force is used.
   Recognise DM_ABORT_ON_INTERNAL_ERRORS env var override in lvm logging fn.
   Fix alloc segfault when extending LV with fewer stripes than in first seg.
   Fix handling of cache policy name.
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 82e37e0..f9d82b0 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -545,20 +545,20 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 			return 2;
 		if (blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL)) {
 			log_error(_msg_failed_offset, type, name);
-			return 0;
+			return  (force < DONT_PROMPT) ? 0 : 2;
 		}
 		if (blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len)) {
 			log_error(_msg_failed_length, type, name);
-			return 0;
+			return  (force < DONT_PROMPT) ? 0 : 2;
 		}
 	} else if (!blkid_probe_lookup_value(probe, "PTTYPE", &type, NULL)) {
 		if (blkid_probe_lookup_value(probe, "PTMAGIC_OFFSET", &offset, NULL)) {
 			log_error(_msg_failed_offset, type, name);
-			return 0;
+			return  (force < DONT_PROMPT) ? 0 : 2;
 		}
 		if (blkid_probe_lookup_value(probe, "PTMAGIC", &magic, &len)) {
 			log_error(_msg_failed_length, type, name);
-			return 0;
+			return  (force < DONT_PROMPT) ? 0 : 2;
 		}
 		usage = "partition table";
 	} else


