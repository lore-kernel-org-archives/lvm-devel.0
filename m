From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 15 Nov 2013 16:00:27 +0100
Subject: [PATCH 1/6] device: add wipe_known_sbs wrapper fn
Message-ID: <5286370B.2010000@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The wipe_known_sbs fn wraps the _wipe_sb fn that is called each known superblock.
Just a cleanup - makes the code more readable, not repeating the same sequence
when used anywhere in the code. We're going to reuse this code...
---
 lib/device/dev-type.c   | 42 ++++++++++++++++++++++++++++++++++++++++++
 lib/device/dev-type.h   |  4 ++++
 lib/metadata/metadata.c | 46 ++++------------------------------------------
 3 files changed, 50 insertions(+), 42 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index a98cf45..4157b33 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -443,6 +443,48 @@ out:
 	return ret;
 }
 
+static int _wipe_sb(struct device *dev, const char *type, const char *name,
+		    int wipe_len, int yes, force_t force,
+		    int (*func)(struct device *dev, uint64_t *signature))
+{
+	int wipe;
+	uint64_t superblock;
+
+	wipe = func(dev, &superblock);
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
+	if (!dev_set(dev, superblock, wipe_len, 0)) {
+		log_error("Failed to wipe %s on %s.", type, name);
+		return 0;
+	}
+
+	return 1;
+}
+
+int wipe_known_sbs(struct device *dev, const char *name, int yes, force_t force)
+{
+	if (!_wipe_sb(dev, "software RAID md superblock", name, 4, yes, force, dev_is_md) ||
+	    !_wipe_sb(dev, "swap signature", name, 10, yes, force, dev_is_swap) ||
+	    !_wipe_sb(dev, "LUKS signature", name, 8, yes, force, dev_is_luks))
+		return 0;
+
+	return 1;
+}
+
 #ifdef __linux__
 
 static unsigned long _dev_topology_attribute(struct dev_types *dt,
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 2fa32db..d92b430 100644
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
+int wipe_known_sbs(struct device *dev, const char *name, int yes, force_t force);
+
 /* Type-specific device properties */
 unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8571e0a..616ca30 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1283,40 +1283,6 @@ int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
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
@@ -1393,14 +1359,10 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
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
+	if (!wipe_known_sbs(dev, name, pp->yes, pp->force)) {
+		log_error("Aborting pvcreate on %s.", name);
+		goto bad;
+	}
 
 	if (sigint_caught())
 		goto_bad;
-- 
1.8.4.2


