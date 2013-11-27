From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 14:52:40 +0000 (UTC)
Subject: master - wiping: add support for blkid wiping
Message-ID: <20131127145240.07FB760E9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eaa23d32732c9bc3dd4f948781b5764cf21d84ba
Commit:        eaa23d32732c9bc3dd4f948781b5764cf21d84ba
Parent:        ab2f858af7a72448b6c015a5984c73f5cdaf3664
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 15 14:50:02 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 15:49:15 2013 +0100

wiping: add support for blkid wiping

This is actually the wipefs functionailty as a matter of fact
(wipefs uses the same libblkid calls).

libblkid is more rich when it comes to detecting various
signatures, including filesystems and users can better
decide what to erase and what should be kept.

The code is shared for both pvcreate (where wiping is necessary
to complete the pvcreate operation) and lvcreate where it's up
to the user to decide.

The verbose output contains a bit more information about the
signature like LABEL and UUID.

For example:
  raw/~ # lvcreate -L16m vg
  WARNING: linux_raid_member signature detected on /dev/vg/lvol0 at offset 4096. Wipe it? [y/n]

or more verbose one:
  raw/~ # lvcreate -L16m vg -v
  ...
     Found existing signature on /dev/vg/lvol0 at offset 4096: LABEL="raw.virt:0" UUID="da6af139-8403-5d06-b8c4-13f6f24b73b1" TYPE="linux_raid_member" USAGE="raid"
WARNING: linux_raid_member signature detected on /dev/vg/lvol0 at offset 4096. Wipe it? [y/n]

The verbose output is the same output as found in blkid.
---
 lib/device/dev-type.c   |  113 ++++++++++++++++++++++++++++++++++++++++++++++-
 lib/device/dev-type.h   |    2 +-
 lib/metadata/lv_manip.c |    2 +-
 lib/metadata/metadata.c |    2 +-
 4 files changed, 115 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index e42349d..04b555b 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -21,6 +21,10 @@
 #include <libgen.h>
 #include <ctype.h>
 
+#ifdef BLKID_WIPING_SUPPORT
+#include <blkid/blkid.h>
+#endif
+
 #include "device-types.h"
 
 struct dev_types *create_dev_types(const char *proc_dir,
@@ -443,6 +447,102 @@ out:
 	return ret;
 }
 
+#ifdef BLKID_WIPING_SUPPORT
+
+static int _blkid_wipe(blkid_probe probe, struct device *dev,
+		       const char *name, int yes, force_t force)
+{
+	const char *offset = NULL, *type = NULL, *magic = NULL,
+		   *usage = NULL, *label = NULL, *uuid = NULL;
+	loff_t offset_value;
+	size_t len;
+
+	if (!blkid_probe_lookup_value(probe, "TYPE", &type, NULL)) {
+		if (!blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL) &&
+		     blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len))
+			return_0;
+	} else if (!blkid_probe_lookup_value(probe, "PTTYPE", &type, NULL)) {
+		if (!blkid_probe_lookup_value(probe, "PTMAGIC_OFFSET", &offset, NULL) &&
+		     blkid_probe_lookup_value(probe, "PTMAGIC", &magic, &len))
+			return_0;
+		usage = "partition table";
+	} else
+		return_0;
+
+	offset_value = strtoll(offset, NULL, 10);
+
+	if (!usage)
+		blkid_probe_lookup_value(probe, "USAGE", &usage, NULL);
+	blkid_probe_lookup_value(probe, "LABEL", &label, NULL);
+	blkid_probe_lookup_value(probe, "UUID", &uuid, NULL);
+
+	log_verbose("Found existing signature on %s at offset %s: LABEL=\"%s\" "
+		    "UUID=\"%s\" TYPE=\"%s\" USAGE=\"%s\"",
+		     name, offset, label, uuid, type, usage);
+
+	if (!yes && (force == PROMPT) &&
+	    yes_no_prompt("WARNING: %s signature detected on %s at offset %s. "
+			  "Wipe it? [y/n] ", type, name, offset) != 'y')
+		return_0;
+
+	log_print_unless_silent("Wiping %s signature on %s.", type, name);
+	if (!dev_set(dev, offset_value, len, 0)) {
+		log_error("Failed to wipe %s signature on %s.", type, name);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _wipe_known_signatures_with_blkid(struct device *dev, const char *name,
+					     int yes, force_t force)
+{
+	blkid_probe probe = NULL;
+	int found = 0, wiped = 0, left = 0;
+	int r = 0;
+
+	/* TODO: Should we check for valid dev - _dev_is_valid(dev)? */
+
+	if (!(probe = blkid_new_probe_from_filename(dev_name(dev)))) {
+		log_error("Failed to create a new blkid probe for device %s.", dev_name(dev));
+		goto out;
+	}
+
+	blkid_probe_enable_partitions(probe, 1);
+	blkid_probe_set_partitions_flags(probe, BLKID_PARTS_MAGIC);
+
+	blkid_probe_enable_superblocks(probe, 1);
+	blkid_probe_set_superblocks_flags(probe, BLKID_SUBLKS_LABEL |
+						 BLKID_SUBLKS_UUID |
+						 BLKID_SUBLKS_TYPE |
+						 BLKID_SUBLKS_USAGE |
+						 BLKID_SUBLKS_VERSION |
+						 BLKID_SUBLKS_MAGIC |
+						 BLKID_SUBLKS_BADCSUM);
+
+	while (!blkid_do_probe(probe)) {
+		found++;
+		if (_blkid_wipe(probe, dev, name, yes, force))
+			wiped++;
+	}
+
+	if (!found)
+		r = 1;
+
+	left = found - wiped;
+	if (!left)
+		r = 1;
+	else
+		log_warn("%d existing signature%s left on the device.",
+			  left, left > 1 ? "s" : "");
+out:
+	if (probe)
+		blkid_free_probe(probe);
+	return r;
+}
+
+#endif /* BLKID_WIPING_SUPPORT */
+
 static int _wipe_signature(struct device *dev, const char *type, const char *name,
 			   int wipe_len, int yes, force_t force,
 			   int (*signature_detection_fn)(struct device *dev, uint64_t *offset_found))
@@ -475,7 +575,8 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 	return 1;
 }
 
-int wipe_known_signatures(struct device *dev, const char *name, int yes, force_t force)
+static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
+					   int yes, force_t force)
 {
 	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, dev_is_md) ||
 	    !_wipe_signature(dev, "swap signature", name, 10, yes, force, dev_is_swap) ||
@@ -485,6 +586,16 @@ int wipe_known_signatures(struct device *dev, const char *name, int yes, force_t
 	return 1;
 }
 
+int wipe_known_signatures(struct cmd_context *cmd, struct device *dev,
+			  const char *name, int yes, force_t force)
+{
+#ifdef BLKID_WIPING_SUPPORT
+	if (find_config_tree_bool(cmd, allocation_use_blkid_wiping_CFG, NULL))
+		return _wipe_known_signatures_with_blkid(dev, name, yes, force);
+#endif
+	return _wipe_known_signatures_with_lvm(dev, name, yes, force);
+}
+
 #ifdef __linux__
 
 static int _snprintf_attr(char *buf, size_t buf_size, const char *sysfs_dir,
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 895a172..39d947b 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -60,7 +60,7 @@ int dev_is_swap(struct device *dev, uint64_t *signature);
 int dev_is_luks(struct device *dev, uint64_t *signature);
 
 /* Signature wiping. */
-int wipe_known_signatures(struct device *dev, const char *name, int yes, force_t force);
+int wipe_known_signatures(struct cmd_context *cmd, struct device *dev, const char *name, int yes, force_t force);
 
 /* Type-specific device properties */
 unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 521d058..2480942 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5429,7 +5429,7 @@ int wipe_lv(struct cmd_context *cmd, struct wipe_lv_params *wp)
 	if (wp->do_wipe_signatures) {
 		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
 			     wp->lv->vg->name, wp->lv->name);
-		if (!wipe_known_sbs(dev, name, wp->yes, wp->force))
+		if (!wipe_known_signatures(cmd, dev, name, wp->yes, wp->force))
 			stack;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f0230f1..5c87ab6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1330,7 +1330,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		goto bad;
 	}
 
-	if (!wipe_known_signatures(dev, name, pp->yes, pp->force)) {
+	if (!wipe_known_signatures(cmd, dev, name, pp->yes, pp->force)) {
 		log_error("Aborting pvcreate on %s.", name);
 		goto bad;
 	}


