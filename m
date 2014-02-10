From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 10 Feb 2014 12:31:52 +0000 (UTC)
Subject: master - wiping: wipe DM_snapshot_cow signature without prompt in newly created LVs
Message-ID: <20140210123152.40BC260990@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed166a3b1d3290ad887d8f83c24a8d8877713d3c
Commit:        ed166a3b1d3290ad887d8f83c24a8d8877713d3c
Parent:        56358160948554e1eb8dc7c5a86dbad4216376fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 10 13:28:13 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 10 13:28:13 2014 +0100

wiping: wipe DM_snapshot_cow signature without prompt in newly created LVs

The libblkid can detect DM_snapshot_cow signature and when creating
new LVs with blkid wiping used (allocation/use_blkid_wiping=1 lvm.conf
setting and --wipe y used at the same time - which it is by default).

Do not issue any prompts about this signature when new LV is created
and just wipe it right away without asking questions. Still keep the
log in verbose mode though.
---
 WHATS_NEW               |    1 +
 lib/device/dev-type.c   |   47 ++++++++++++++++++++++++++++++++---------------
 lib/device/dev-type.h   |    6 +++++-
 lib/metadata/lv_manip.c |    4 +++-
 lib/metadata/metadata.c |    4 +++-
 5 files changed, 44 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dbacf01..043feae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Wipe DM_snapshot_cow signature without prompt in new LVs with blkid wiping.
   Avoid exposing temporary devices when initializing raid metadata volumes.
   Add internal tags command to display any tags defined on the host.
   Prohibit use of external origin with size incompatible with thin pool.
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index e67169b..87a6659 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -449,19 +449,27 @@ out:
 
 #ifdef BLKID_WIPING_SUPPORT
 
+static inline int _type_in_flag_list(const char *type, uint32_t flag_list)
+{
+	return (((flag_list & TYPE_LVM2_MEMBER) && !strcmp(type, "LVM2_member")) ||
+		((flag_list & TYPE_LVM1_MEMBER) && !strcmp(type, "LVM1_member")) ||
+		((flag_list & TYPE_DM_SNAPSHOT_COW) && !strcmp(type, "DM_snapshot_cow")));
+}
+
 static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
-		       int exclude_lvm_member, int yes, force_t force)
+		       uint32_t types_to_exclude, uint32_t types_no_prompt,
+		       int yes, force_t force)
 {
 	static const char* msg_failed_offset = "Failed to get offset of the %s signature on %s.";
 	static const char* msg_failed_length = "Failed to get length of the %s signature on %s.";
+	static const char* msg_wiping = "Wiping %s signature on %s.";
 	const char *offset = NULL, *type = NULL, *magic = NULL,
 		   *usage = NULL, *label = NULL, *uuid = NULL;
 	loff_t offset_value;
 	size_t len;
 
 	if (!blkid_probe_lookup_value(probe, "TYPE", &type, NULL)) {
-		if (exclude_lvm_member &&
-		    (!strcmp(type, "LVM1_member") || !strcmp(type, "LVM2_member")))
+		if (_type_in_flag_list(type, types_to_exclude))
 			return 1;
 		if (blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL)) {
 			log_error(msg_failed_offset, type, name);
@@ -495,12 +503,15 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		    "UUID=\"%s\" TYPE=\"%s\" USAGE=\"%s\"",
 		     name, offset, label, uuid, type, usage);
 
-	if (!yes && (force == PROMPT) &&
-	    yes_no_prompt("WARNING: %s signature detected on %s at offset %s. "
-			  "Wipe it? [y/n] ", type, name, offset) != 'y')
-		return_0;
+	if (!_type_in_flag_list(type, types_no_prompt)) {
+		if (!yes && (force == PROMPT) &&
+		    yes_no_prompt("WARNING: %s signature detected on %s at offset %s. "
+				  "Wipe it? [y/n] ", type, name, offset) != 'y')
+			return_0;
+		log_print_unless_silent(msg_wiping, type, name);
+	} else
+		log_verbose(msg_wiping, type, name);
 
-	log_print_unless_silent("Wiping %s signature on %s.", type, name);
 	if (!dev_set(dev, offset_value, len, 0)) {
 		log_error("Failed to wipe %s signature on %s.", type, name);
 		return 0;
@@ -510,7 +521,8 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 }
 
 static int _wipe_known_signatures_with_blkid(struct device *dev, const char *name,
-					     int exclude_lvm_member,
+					     uint32_t types_to_exclude,
+					     uint32_t types_no_prompt,
 					     int yes, force_t force)
 {
 	blkid_probe probe = NULL;
@@ -538,7 +550,7 @@ static int _wipe_known_signatures_with_blkid(struct device *dev, const char *nam
 
 	while (!blkid_do_probe(probe)) {
 		found++;
-		if (_blkid_wipe(probe, dev, name, exclude_lvm_member, yes, force))
+		if (_blkid_wipe(probe, dev, name, types_to_exclude, types_no_prompt, yes, force))
 			wiped++;
 	}
 
@@ -592,7 +604,8 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 }
 
 static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
-					   int exclude_lvm_member,
+					   uint32_t types_to_exclude __attribute__((unused)),
+					   uint32_t types_no_prompt __attribute__((unused)),
 					   int yes, force_t force)
 {
 	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, dev_is_md) ||
@@ -604,16 +617,20 @@ static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
 }
 
 int wipe_known_signatures(struct cmd_context *cmd, struct device *dev,
-			  const char *name, int exclude_lvm_member,
-			  int yes, force_t force)
+			  const char *name, uint32_t types_to_exclude,
+			  uint32_t types_no_prompt, int yes, force_t force)
 {
 #ifdef BLKID_WIPING_SUPPORT
 	if (find_config_tree_bool(cmd, allocation_use_blkid_wiping_CFG, NULL))
 		return _wipe_known_signatures_with_blkid(dev, name,
-				exclude_lvm_member, yes, force);
+							 types_to_exclude,
+							 types_no_prompt,
+							 yes, force);
 #endif
 	return _wipe_known_signatures_with_lvm(dev, name,
-			exclude_lvm_member, yes, force);
+					       types_to_exclude,
+					       types_no_prompt,
+					       yes, force);
 }
 
 #ifdef __linux__
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 284280e..b1520ee 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -60,8 +60,12 @@ int dev_is_swap(struct device *dev, uint64_t *signature);
 int dev_is_luks(struct device *dev, uint64_t *signature);
 
 /* Signature wiping. */
+#define TYPE_LVM1_MEMBER	0x001
+#define TYPE_LVM2_MEMBER	0x002
+#define TYPE_DM_SNAPSHOT_COW	0x004
 int wipe_known_signatures(struct cmd_context *cmd, struct device *dev, const char *name,
-			  int exclude_lvm_member, int yes, force_t force);
+			  uint32_t types_to_exclude, uint32_t types_no_prompt,
+			  int yes, force_t force);
 
 /* Type-specific device properties */
 unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 96515d7..d0b6c9e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5538,7 +5538,9 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 	if (wp.do_wipe_signatures) {
 		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
 			     lv->vg->name, lv->name);
-		if (!wipe_known_signatures(lv->vg->cmd, dev, name, 0, wp.yes, wp.force))
+		if (!wipe_known_signatures(lv->vg->cmd, dev, name, 0,
+					   TYPE_DM_SNAPSHOT_COW,
+					   wp.yes, wp.force))
 			stack;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 16a5411..88447a3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1372,7 +1372,9 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		goto bad;
 	}
 
-	if (!wipe_known_signatures(cmd, dev, name, 1, pp->yes, pp->force)) {
+	if (!wipe_known_signatures(cmd, dev, name,
+				   TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
+				   0, pp->yes, pp->force)) {
 		log_error("Aborting pvcreate on %s.", name);
 		goto bad;
 	}


