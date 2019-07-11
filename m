From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jul 2019 12:42:29 -0400
Subject: master - md component detection for differing PV and device sizes
Message-ID: <201907111642.x6BGgTV5028657@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f17353e3e604ad2d80bcd77ea0a6a93472e6b5bd
Commit:        f17353e3e604ad2d80bcd77ea0a6a93472e6b5bd
Parent:        d2b88f271512c56737e27bbdfbd0e0b6891b4cd0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 9 13:32:41 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 9 13:40:41 2019 -0500

md component detection for differing PV and device sizes

This check was mistakenly removed when shifting code in commit
"separate code for setting devices from metadata parsing".

Put it back with some new conditions.
---
 lib/metadata/metadata.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 121cf4f..f19df3d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3504,19 +3504,41 @@ static void _set_pv_device(struct format_instance *fid,
 			   struct physical_volume *pv)
 {
 	char buffer[64] __attribute__((aligned(8)));
+	struct cmd_context *cmd = fid->fmt->cmd;
+	struct device *dev;
 	uint64_t size;
 
-	if (!(pv->dev = lvmcache_device_from_pvid(fid->fmt->cmd, &pv->id, &pv->label_sector))) {
+	if (!(dev = lvmcache_device_from_pvid(cmd, &pv->id, &pv->label_sector))) {
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			buffer[0] = '\0';
 
-		if (fid->fmt->cmd && !fid->fmt->cmd->pvscan_cache_single)
+		if (cmd && !cmd->pvscan_cache_single)
 			log_warn("WARNING: Couldn't find device with uuid %s.", buffer);
 		else
 			log_debug_metadata("Couldn't find device with uuid %s.", buffer);
 	}
 
 	/*
+	 * If the device and PV are not the size, it's a clue that we might
+	 * be reading an MD component (but not necessarily). Skip this check:
+	 * . if md component detection is disabled
+	 * . if we are already doing full a md check in label scan
+	 * . if md_component_checks is auto, not none (full means use_full_md_check is set)
+	 */
+	if (dev && (pv->size != dev->size) && cmd &&
+	    cmd->md_component_detection &&
+	    !cmd->use_full_md_check &&
+	    !strcmp(cmd->md_component_checks, "auto")) {
+		if (dev_is_md_component(dev, NULL, 1)) {
+			log_warn("WARNING: device %s is an md component, not setting device for PV.",
+				 dev_name(dev));
+			dev = NULL;
+		}
+	}
+
+	pv->dev = dev;
+
+	/*
 	 * A previous command wrote the VG while this dev was missing, so
 	 * the MISSING flag was included in the PV.
 	 */


