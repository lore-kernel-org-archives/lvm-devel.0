From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:47 +0000 (GMT)
Subject: main - cov: check label_read_pvid return value
Message-ID: <20210423210547.1B523394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bf461b99c6d26e550835b77eaffe2204cbc9bed3
Commit:        bf461b99c6d26e550835b77eaffe2204cbc9bed3
Parent:        7e135868374601020920094f135d678c688d0950
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 12:31:49 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: check label_read_pvid return value

Command can early exit when function returns 0.
---
 tools/lvmdevices.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index b67db7464..c6cb1fcff 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -181,7 +181,8 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 				continue;
 			dev = du->dev;
 
-			label_read_pvid(dev);
+			if (!label_read_pvid(dev))
+				continue;
 
 			/*
 			 * label_read_pvid has read the first 4K of the device
@@ -283,7 +284,8 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * (it's ok if the device is not a PV and has no PVID)
 		 */
 		label_scan_setup_bcache();
-		label_read_pvid(dev);
+		if (!label_read_pvid(dev))
+			goto_bad;
 
 		/*
 		 * Allow filtered devices to be added to devices_file, but


