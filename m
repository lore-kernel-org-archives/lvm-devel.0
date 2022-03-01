From: David Teigland <teigland@sourceware.org>
Date: Tue,  1 Mar 2022 20:11:44 +0000 (GMT)
Subject: main - devices: only close PVs on LVs when scan_lvs is enabled
Message-ID: <20220301201144.EFDF73858C20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc73d99886dfd6e0da3c6ca685669f77fac3c1cd
Commit:        cc73d99886dfd6e0da3c6ca685669f77fac3c1cd
Parent:        7b1a857d5ac480b789af07d85e55bc87c6a76934
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 1 12:22:46 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 1 14:11:05 2022 -0600

devices: only close PVs on LVs when scan_lvs is enabled

This code is only needed when lvm scans PVs that are stacked on LVs.
---
 lib/label/label.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index c20863875..e6bc791a7 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1661,9 +1661,11 @@ void label_scan_invalidate_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 	dev_t devt;
 
 	/*
-	 * FIXME: this is all unnecessary unless there are PVs stacked on LVs,
-	 * so we can skip all of this if scan_lvs=0.
+	 * This is only needed when the command sees PVs stacked on LVs which
+	 * will only happen with scan_lvs=1.
 	 */
+	if (!cmd->scan_lvs)
+		return;
 	log_debug("invalidating devs for any pvs on lvs");
 
 	if (get_device_list(NULL, &devs, &devs_features)) {


