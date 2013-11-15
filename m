From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 15 Nov 2013 16:02:26 +0100
Subject: [PATCH 6/6] wiping: add support for blkid wiping
Message-ID: <52863782.7030900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is actually the wipefs functionailty as a matter of fact
(wipefs uses the same libblkid calls).

libblkid is more rich when it comes to detecting various
superblocks, including filesystems and users can better
decide what to erase and what should be kept.

The code is shared for both pvcreate (where wiping is necessary
to complete the pvcreate operation) and lvcreate where it's up
to the user to decide.

The verbose output contains a bit more information about the
signature like LABEL and UUID.

Some examples:

[0] f20/~ # mkfs.ext3 /dev/sda
[0] f20/~ # pvcreate /dev/sda
WARNING: ext3 signature detected on /dev/sda at offset 1080. Wipe it? y/n] n
  1 existing signature left on the device.
  Aborting pvcreate on /dev/sda.

or

[0] f20/~ # pvcreate /dev/sda
WARNING: ext3 signature detected on /dev/sda at offset 1080. Wipe it? [y/n] y
  Wiping ext3 signature on /dev/sda.
  Physical volume "/dev/sda" successfully created

The same applies for LV wiping (the new -Wy option, here also with verbose output
to show more details like LABEL and UUID}:

[0] f20/~ # lvcreate -L32m -Wy -v vg
    ...
    Found existing signature on /dev/vg/lvol0 at offset 4096: TYPE='linux_raid_member', USAGE='raid', LABEL='f20.virt:0', UUID='f8c52f33-2218-6179-6128-8e060c4853bc'
WARNING: linux_raid_member signature detected on /dev/vg/lvol0 at offset 4096. Wipe it? [y/n]

[0] f20/~ # lvcreate -L32m -Wy -v vg
    ...
    Found existing signature on /dev/vg/lvol0 at offset 1080: TYPE='ext4', USAGE='filesystem', LABEL='MyLabel', UUID='62550ac7-d1fe-4f3e-8675-40249774681e'
WARNING: ext4 signature detected on /dev/vg/lvol0 at offset 1080. Wipeit? [y/n]

etc.
---
 lib/device/dev-type.c | 101 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 101 insertions(+)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 4157b33..5625103 100644
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
@@ -443,6 +447,101 @@ out:
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
+	log_verbose("Found existing signature on %s at offset %s: TYPE=\'%s\', USAGE=\'%s\', "
+		    "LABEL=\'%s\', UUID=\'%s\'", name, offset, type, usage, label, uuid);
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
+int wipe_known_sbs(struct device *dev, const char *name, int yes, force_t force)
+{
+	blkid_probe probe = NULL;
+	int found = 0, wiped = 0, left = 0;
+	int r = 0;
+
+	/*if (!_dev_is_valid(dev))
+		return 0;*/
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
+#else
+
 static int _wipe_sb(struct device *dev, const char *type, const char *name,
 		    int wipe_len, int yes, force_t force,
 		    int (*func)(struct device *dev, uint64_t *signature))
@@ -485,6 +584,8 @@ int wipe_known_sbs(struct device *dev, const char *name, int yes, force_t force)
 	return 1;
 }
 
+#endif /* BLKID_WIPING_SUPPORT */
+
 #ifdef __linux__
 
 static unsigned long _dev_topology_attribute(struct dev_types *dt,
-- 
1.8.4.2


