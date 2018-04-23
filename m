From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:54:27 -0400
Subject: master - lvmdiskscan: use the new label_scan
Message-ID: <201804231354.w3NDsR3C001446@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96a61337b00a250f69e7a8e6ac390c47c36c2c0f
Commit:        96a61337b00a250f69e7a8e6ac390c47c36c2c0f
Parent:        28255e3eeef13a0e73a40d533623b22dd9db89cb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 14 16:43:26 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

lvmdiskscan: use the new label_scan

instead of doing it's own.
---
 tools/lvmdiskscan.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index cb688b5..7e2fc88 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -87,7 +87,6 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	uint64_t size;
 	struct dev_iter *iter;
 	struct device *dev;
-	struct label *label;
 
 	/* initialise these here to avoid problems with the lvm shell */
 	disks_found = 0;
@@ -105,10 +104,10 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 		return ECMD_FAILED;
 	}
 
-	/* Do scan */
+	label_scan(cmd);
+
 	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
-		/* Try if it is a PV first */
-		if ((label_read(dev, &label, UINT64_C(0)))) {
+		if (lvmcache_has_dev_info(dev)) {
 			if (!dev_get_size(dev, &size)) {
 				log_error("Couldn't get size of \"%s\"",
 					  dev_name(dev));


