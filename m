From: Milan Broz <mbroz@redhat.com>
Date: Thu, 12 Aug 2010 16:07:56 +0200
Subject: [PATCH 1/4] Change the pvcreate swap/md logic
In-Reply-To: <cover.1281621747.git.mbroz@redhat.com>
References: <cover.1281621747.git.mbroz@redhat.com>
Message-ID: <c12dc9187579de7ec95c1198e6921298c96d094b.1281621747.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

pvcreate detects MD and swap signature.

The logic hidden there is not only documented but it is also
user unfriendly. Who invented this logic should run pvcreate
on its own critical MD device to see why;-)

This patch
 - create one function instead of duplication code
 - asks if user want to overwrite signature
 - allow aborting (!)
 (Please note that writing LVM signarute without wiping old
 is wrong, it confuses blkid, MD will not work anyway and
 swap and LUKS is broken too.)

Question is ignore if --yes is given or --force switch is used.
(See later patch also.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |   70 ++++++++++++++++++++++++-----------------------
 1 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6cd7793..db196d6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1526,6 +1526,40 @@ int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
 	return 1;
 }
 
+static int _wipe_sb(struct device *dev, const char *type, const char *name,
+		    int wipe_len, struct pvcreate_params *pp,
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
+	if (!pp->yes && (pp->force == PROMPT) &&
+	    yes_no_prompt("WARNING: %s detected on %s. Wipe it? [y/n] ",
+			  type, name) != 'y') {
+		log_error("Aborting pvcreate on %s.", name);
+		return 0;
+	}
+
+	log_print("Wiping %s on %s.", type, name);
+	if (!dev_set(dev, superblock, wipe_len, 0)) {
+		log_error("Failed to wipe %s on %s.", type, name);
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * See if we may pvcreate on this device.
  * 0 indicates we may not.
@@ -1535,8 +1569,6 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 {
 	struct physical_volume *pv;
 	struct device *dev;
-	uint64_t md_superblock, swap_signature;
-	int wipe_md, wipe_swap;
 	struct dm_list mdas;
 
 	dm_list_init(&mdas);
@@ -1602,41 +1634,11 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		return 0;
 	}
 
-	/* Wipe superblock? */
-	if ((wipe_md = dev_is_md(dev, &md_superblock)) == 1 &&
-	    ((!pp->idp && !pp->restorefile) || pp->yes ||
-	     (yes_no_prompt("Software RAID md superblock "
-			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
-		log_print("Wiping software RAID md superblock on %s", name);
-		if (!dev_set(dev, md_superblock, 4, 0)) {
-			log_error("Failed to wipe RAID md superblock on %s",
-				  name);
-			return 0;
-		}
-	}
-
-	if (wipe_md == -1) {
-		log_error("Fatal error while trying to detect software "
-			  "RAID md superblock on %s", name);
+	if (!_wipe_sb(dev, "software RAID md superblock", name, 4, pp, dev_is_md))
 		return 0;
-	}
-
-	if ((wipe_swap = dev_is_swap(dev, &swap_signature)) == 1 &&
-	    ((!pp->idp && !pp->restorefile) || pp->yes ||
-	     (yes_no_prompt("Swap signature detected on %s. Wipe it? [y/n] ",
-			    name) == 'y'))) {
-		log_print("Wiping swap signature on %s", name);
-		if (!dev_set(dev, swap_signature, 10, 0)) {
-			log_error("Failed to wipe swap signature on %s", name);
-			return 0;
-		}
-	}
 
-	if (wipe_swap == -1) {
-		log_error("Fatal error while trying to detect swap "
-			  "signature on %s", name);
+	if (!_wipe_sb(dev, "swap signature", name, 10, pp, dev_is_swap))
 		return 0;
-	}
 
 	if (sigint_caught())
 		return 0;
-- 
1.7.1


