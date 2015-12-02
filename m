From: Lidong Zhong <lzhong@suse.com>
Date: Wed,  2 Dec 2015 17:10:22 +0800
Subject: [PATCH] lvmdiskscan: improve the output of this command
Message-ID: <1449047422-14087-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
 tools/lvmdiskscan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index 0320a76..a3f83f7 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -144,14 +144,14 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	/* Display totals */
 	if (!arg_count(cmd, lvmpartition_ARG)) {
 		log_print("%d disk%s",
-			  disks_found, disks_found == 1 ? "" : "s");
+			  disks_found, disks_found <= 1 ? "" : "s");
 		log_print("%d partition%s",
-			  parts_found, parts_found == 1 ? "" : "s");
+			  parts_found, parts_found <= 1 ? "" : "s");
 	}
 	log_print("%d LVM physical volume whole disk%s",
-		  pv_disks_found, pv_disks_found == 1 ? "" : "s");
+		  pv_disks_found, pv_disks_found <= 1 ? "" : "s");
 	log_print("%d LVM physical volume%s",
-		  pv_parts_found, pv_parts_found == 1 ? "" : "s");
+		  pv_parts_found, pv_parts_found <= 1 ? "" : "s");
 
 	return ECMD_PROCESSED;
 }
-- 
2.1.2


