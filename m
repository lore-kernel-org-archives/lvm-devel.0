From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:32 +0000 (UTC)
Subject: master - cleanup: use string constant with '_'
Message-ID: <20140211180132.07E7E60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5d59d96187d4ba6efa88cca53f608cd646f461a
Commit:        e5d59d96187d4ba6efa88cca53f608cd646f461a
Parent:        f86e18bfeb8f047ac3fdc2b7a95e2f80a0bcdbfb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 9 21:33:36 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 19:00:06 2014 +0100

cleanup: use string constant with '_'

---
 lib/device/dev-type.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 87a6659..81100ad 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -460,9 +460,9 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		       uint32_t types_to_exclude, uint32_t types_no_prompt,
 		       int yes, force_t force)
 {
-	static const char* msg_failed_offset = "Failed to get offset of the %s signature on %s.";
-	static const char* msg_failed_length = "Failed to get length of the %s signature on %s.";
-	static const char* msg_wiping = "Wiping %s signature on %s.";
+	static const char _msg_failed_offset[] = "Failed to get offset of the %s signature on %s.";
+	static const char _msg_failed_length[] = "Failed to get length of the %s signature on %s.";
+	static const char _msg_wiping[] = "Wiping %s signature on %s.";
 	const char *offset = NULL, *type = NULL, *magic = NULL,
 		   *usage = NULL, *label = NULL, *uuid = NULL;
 	loff_t offset_value;
@@ -472,20 +472,20 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		if (_type_in_flag_list(type, types_to_exclude))
 			return 1;
 		if (blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL)) {
-			log_error(msg_failed_offset, type, name);
+			log_error(_msg_failed_offset, type, name);
 			return 0;
 		}
 		if (blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len)) {
-			log_error(msg_failed_length, type, name);
+			log_error(_msg_failed_length, type, name);
 			return 0;
 		}
 	} else if (!blkid_probe_lookup_value(probe, "PTTYPE", &type, NULL)) {
 		if (blkid_probe_lookup_value(probe, "PTMAGIC_OFFSET", &offset, NULL)) {
-			log_error(msg_failed_offset, type, name);
+			log_error(_msg_failed_offset, type, name);
 			return 0;
 		}
 		if (blkid_probe_lookup_value(probe, "PTMAGIC", &magic, &len)) {
-			log_error(msg_failed_length, type, name);
+			log_error(_msg_failed_length, type, name);
 			return 0;
 		}
 		usage = "partition table";
@@ -508,9 +508,9 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		    yes_no_prompt("WARNING: %s signature detected on %s at offset %s. "
 				  "Wipe it? [y/n] ", type, name, offset) != 'y')
 			return_0;
-		log_print_unless_silent(msg_wiping, type, name);
+		log_print_unless_silent(_msg_wiping, type, name);
 	} else
-		log_verbose(msg_wiping, type, name);
+		log_verbose(_msg_wiping, type, name);
 
 	if (!dev_set(dev, offset_value, len, 0)) {
 		log_error("Failed to wipe %s signature on %s.", type, name);


