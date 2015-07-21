From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 21 Jul 2015 08:35:47 +0000 (UTC)
Subject: master - wiping: log_warn instead of log_error if blkid wipe ignored for a signature
Message-ID: <20150721083547.655FC60ED7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=697fb353dc5ecf813199c598eed07983868fdd56
Commit:        697fb353dc5ecf813199c598eed07983868fdd56
Parent:        2a7c2539c63f72d6c50df54f53271e567fa948ee
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 21 10:34:04 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 21 10:34:04 2015 +0200

wiping: log_warn instead of log_error if blkid wipe ignored for a signature

Comply with the rules we have for log_error and log_warn...

$ pvcreate /dev/sda1
  Failed to get offset of the xfs_external_log signature on /dev/sda1.
  1 existing signature left on the device.
  Aborting pvcreate on /dev/sda1.

$ pvcreate /dev/sda1 --force
  WARNING: Failed to get offset of the xfs_external_log signature on /dev/sda1.
  Physical volume "/dev/sda1" successfully created
---
 lib/device/dev-type.c |   41 +++++++++++++++++++++++++++++++----------
 1 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index f9d82b0..873e02e 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -528,12 +528,13 @@ static inline int _type_in_flag_list(const char *type, uint32_t flag_list)
 		((flag_list & TYPE_DM_SNAPSHOT_COW) && !strcmp(type, "DM_snapshot_cow")));
 }
 
+#define MSG_FAILED_SIG_OFFSET "Failed to get offset of the %s signature on %s."
+#define MSG_FAILED_SIG_LENGTH "Failed to get length of the %s signature on %s."
+
 static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		       uint32_t types_to_exclude, uint32_t types_no_prompt,
 		       int yes, force_t force)
 {
-	static const char _msg_failed_offset[] = "Failed to get offset of the %s signature on %s.";
-	static const char _msg_failed_length[] = "Failed to get length of the %s signature on %s.";
 	static const char _msg_wiping[] = "Wiping %s signature on %s.";
 	const char *offset = NULL, *type = NULL, *magic = NULL,
 		   *usage = NULL, *label = NULL, *uuid = NULL;
@@ -544,21 +545,41 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		if (_type_in_flag_list(type, types_to_exclude))
 			return 2;
 		if (blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL)) {
-			log_error(_msg_failed_offset, type, name);
-			return  (force < DONT_PROMPT) ? 0 : 2;
+			if (force < DONT_PROMPT) {
+				log_error(MSG_FAILED_SIG_OFFSET, type, name);
+				return 0;
+			} else {
+				log_error("WARNING: " MSG_FAILED_SIG_OFFSET, type, name);
+				return 2;
+			}
 		}
 		if (blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len)) {
-			log_error(_msg_failed_length, type, name);
-			return  (force < DONT_PROMPT) ? 0 : 2;
+			if (force < DONT_PROMPT) {
+				log_error(MSG_FAILED_SIG_LENGTH, type, name);
+				return 0;
+			} else {
+				log_warn("WARNING: " MSG_FAILED_SIG_LENGTH, type, name);
+				return 2;
+			}
 		}
 	} else if (!blkid_probe_lookup_value(probe, "PTTYPE", &type, NULL)) {
 		if (blkid_probe_lookup_value(probe, "PTMAGIC_OFFSET", &offset, NULL)) {
-			log_error(_msg_failed_offset, type, name);
-			return  (force < DONT_PROMPT) ? 0 : 2;
+			if (force < DONT_PROMPT) {
+				log_error(MSG_FAILED_SIG_OFFSET, type, name);
+				return 0;
+			} else {
+				log_warn("WARNING: " MSG_FAILED_SIG_OFFSET, type, name);
+				return 2;
+			}
 		}
 		if (blkid_probe_lookup_value(probe, "PTMAGIC", &magic, &len)) {
-			log_error(_msg_failed_length, type, name);
-			return  (force < DONT_PROMPT) ? 0 : 2;
+			if (force < DONT_PROMPT) {
+				log_error(MSG_FAILED_SIG_LENGTH, type, name);
+				return 0;
+			} else {
+				log_warn("WARNING: " MSG_FAILED_SIG_LENGTH, type, name);
+				return 2;
+			}
 		}
 		usage = "partition table";
 	} else


