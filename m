From: David Teigland <teigland@sourceware.org>
Date: Fri, 23 Apr 2021 22:37:36 +0000 (GMT)
Subject: main - Revert "cov: check label_read_pvid return value"
Message-ID: <20210423223736.3CB953854814@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fcbed26393f57d49daa7da73922b1a922f9523a2
Commit:        fcbed26393f57d49daa7da73922b1a922f9523a2
Parent:        9cdd4dcca7e6d166e44270a81425a50e598836f4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 23 17:12:24 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 23 17:12:24 2021 -0500

Revert "cov: check label_read_pvid return value"

This reverts commit bf461b99c6d26e550835b77eaffe2204cbc9bed3.

label_read_pvid returns 0 for non-PVs and these callers want
to handle non-PVs.
---
 tools/lvmdevices.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index c6cb1fcff..b67db7464 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -181,8 +181,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 				continue;
 			dev = du->dev;
 
-			if (!label_read_pvid(dev))
-				continue;
+			label_read_pvid(dev);
 
 			/*
 			 * label_read_pvid has read the first 4K of the device
@@ -284,8 +283,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * (it's ok if the device is not a PV and has no PVID)
 		 */
 		label_scan_setup_bcache();
-		if (!label_read_pvid(dev))
-			goto_bad;
+		label_read_pvid(dev);
 
 		/*
 		 * Allow filtered devices to be added to devices_file, but


