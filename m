From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 14:52:27 +0000 (UTC)
Subject: master - device: cleanup signature wiping functions
Message-ID: <20131127145227.8583660FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03c941a4caf411f21045670e205ccdd975be27c7
Commit:        03c941a4caf411f21045670e205ccdd975be27c7
Parent:        120df5561088f4a5277716117339d9212b666214
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 6 15:09:29 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 12:56:58 2013 +0100

device: cleanup signature wiping functions

The wipe_known_signatures fn now wraps the _wipe_signature fn that is called
for each known signature (currently md, swap and luks). This patch makes the
code more readable, not repeating the same sequence when used anywhere in the
code. We're going to reuse this code later...
---
 lib/device/dev-luks.c   |    5 +++--
 lib/device/dev-md.c     |    6 +++---
 lib/device/dev-swap.c   |    7 +++----
 lib/device/dev-type.c   |   42 ++++++++++++++++++++++++++++++++++++++++++
 lib/device/dev-type.h   |    4 ++++
 lib/metadata/metadata.c |   46 ++++------------------------------------------
 6 files changed, 59 insertions(+), 51 deletions(-)

diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index 2671d62..572fd1d 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -18,7 +18,7 @@
 #define LUKS_SIGNATURE "LUKS\xba\xbe"
 #define LUKS_SIGNATURE_SIZE 6
 
-int dev_is_luks(struct device *dev, uint64_t *signature)
+int dev_is_luks(struct device *dev, uint64_t *offset_found)
 {
 	char buf[LUKS_SIGNATURE_SIZE];
 	int ret = -1;
@@ -28,7 +28,8 @@ int dev_is_luks(struct device *dev, uint64_t *signature)
 		return -1;
 	}
 
-	*signature = 0;
+	if (offset_found)
+		*offset_found = 0;
 
 	if (!dev_read(dev, 0, LUKS_SIGNATURE_SIZE, buf))
 		goto_out;
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 9af8074..d6a7609 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -81,7 +81,7 @@ static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 /*
  * Returns -1 on error
  */
-int dev_is_md(struct device *dev, uint64_t *sb)
+int dev_is_md(struct device *dev, uint64_t *offset_found)
 {
 	int ret = 1;
 	md_minor_version_t minor;
@@ -120,8 +120,8 @@ out:
 	if (!dev_close(dev))
 		stack;
 
-	if (ret && sb)
-		*sb = sb_offset;
+	if (ret && offset_found)
+		*offset_found = sb_offset;
 
 	return ret;
 }
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index cc44008..f506eda 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -36,7 +36,7 @@ _swap_detect_signature(const char *buf)
 	return 0;
 }
 
-int dev_is_swap(struct device *dev, uint64_t *signature)
+int dev_is_swap(struct device *dev, uint64_t *offset_found)
 {
 	char buf[10];
 	uint64_t size;
@@ -53,8 +53,6 @@ int dev_is_swap(struct device *dev, uint64_t *signature)
 		return -1;
 	}
 
-	*signature = 0;
-
 	for (page = 0x1000; page <= MAX_PAGESIZE; page <<= 1) {
 		/*
 		 * skip 32k pagesize since this does not seem to be supported
@@ -69,7 +67,8 @@ int dev_is_swap(struct device *dev, uint64_t *signature)
 			break;
 		}
 		if (_swap_detect_signature(buf)) {
-			*signature = page - SIGNATURE_SIZE;
+			if (offset_found)
+				*offset_found = page - SIGNATURE_SIZE;
 			ret = 1;
 			break;
 		}
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index f3f29b2..e42349d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -443,6 +443,48 @@ out:
 	return ret;
 }
 
+static int _wipe_signature(struct device *dev, const char *type, const char *name,
+			   int wipe_len, int yes, force_t force,
+			   int (*signature_detection_fn)(struct device *dev, uint64_t *offset_found))
+{
+	int wipe;
+	uint64_t offset_found;
+
+	wipe = signature_detection_fn(dev, &offset_found);
+	if (wipe == -1) {
+		log_error("Fatal error while trying to detect %s on %s.",
+			  type, name);
+		return 0;
+	}
+
+	if (wipe == 0)
+		return 1;
+
+	/* Specifying --yes => do not ask. */
+	if (!yes && (force == PROMPT) &&
+	    yes_no_prompt("WARNING: %s detected on %s. Wipe it? [y/n] ",
+			  type, name) != 'y')
+		return_0;
+
+	log_print_unless_silent("Wiping %s on %s.", type, name);
+	if (!dev_set(dev, offset_found, wipe_len, 0)) {
+		log_error("Failed to wipe %s on %s.", type, name);
+		return 0;
+	}
+
+	return 1;
+}
+
+int wipe_known_signatures(struct device *dev, const char *name, int yes, force_t force)
+{
+	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, dev_is_md) ||
+	    !_wipe_signature(dev, "swap signature", name, 10, yes, force, dev_is_swap) ||
+	    !_wipe_signature(dev, "LUKS signature", name, 8, yes, force, dev_is_luks))
+		return 0;
+
+	return 1;
+}
+
 #ifdef __linux__
 
 static int _snprintf_attr(char *buf, size_t buf_size, const char *sysfs_dir,
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 2fa32db..895a172 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -16,6 +16,7 @@
 #define _LVM_DEV_TYPE_H
 
 #include "device.h"
+#include "display.h"
 
 #define NUMBER_OF_MAJORS 4096
 
@@ -58,6 +59,9 @@ int dev_is_md(struct device *dev, uint64_t *sb);
 int dev_is_swap(struct device *dev, uint64_t *signature);
 int dev_is_luks(struct device *dev, uint64_t *signature);
 
+/* Signature wiping. */
+int wipe_known_signatures(struct device *dev, const char *name, int yes, force_t force);
+
 /* Type-specific device properties */
 unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c71ec30..f0230f1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1268,40 +1268,6 @@ int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
 	return 1;
 }
 
-static int _wipe_sb(struct device *dev, const char *type, const char *name,
-		    int wipe_len, struct pvcreate_params *pp,
-		    int (*func)(struct device *dev, uint64_t *signature))
-{
-	int wipe;
-	uint64_t superblock;
-
-	wipe = func(dev, &superblock);
-	if (wipe == -1) {
-		log_error("Fatal error while trying to detect %s on %s.",
-			  type, name);
-		return 0;
-	}
-
-	if (wipe == 0)
-		return 1;
-
-	/* Specifying --yes => do not ask. */
-	if (!pp->yes && (pp->force == PROMPT) &&
-	    yes_no_prompt("WARNING: %s detected on %s. Wipe it? [y/n] ",
-			  type, name) != 'y') {
-		log_error("Aborting pvcreate on %s.", name);
-		return 0;
-	}
-
-	log_print_unless_silent("Wiping %s on %s.", type, name);
-	if (!dev_set(dev, superblock, wipe_len, 0)) {
-		log_error("Failed to wipe %s on %s.", type, name);
-		return 0;
-	}
-
-	return 1;
-}
-
 /*
  * See if we may pvcreate on this device.
  * 0 indicates we may not.
@@ -1364,14 +1330,10 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		goto bad;
 	}
 
-	if (!_wipe_sb(dev, "software RAID md superblock", name, 4, pp, dev_is_md))
-		goto_bad;
-
-	if (!_wipe_sb(dev, "swap signature", name, 10, pp, dev_is_swap))
-		goto_bad;
-
-	if (!_wipe_sb(dev, "LUKS signature", name, 8, pp, dev_is_luks))
-		goto_bad;
+	if (!wipe_known_signatures(dev, name, pp->yes, pp->force)) {
+		log_error("Aborting pvcreate on %s.", name);
+		goto bad;
+	}
 
 	if (sigint_caught())
 		goto_bad;


