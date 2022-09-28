From: David Teigland <teigland@sourceware.org>
Date: Wed, 28 Sep 2022 16:20:12 +0000 (GMT)
Subject: main - lvresize: exclude new fs handling at build time
Message-ID: <20220928162012.AC8593858016@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1924fed30807ac0d355d2c6527d2f0a1d7efafcc
Commit:        1924fed30807ac0d355d2c6527d2f0a1d7efafcc
Parent:        b39ad99325342f2cdc7a9944f11b6d6ae120febe
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 28 11:02:17 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 28 11:16:43 2022 -0500

lvresize: exclude new fs handling at build time

Exclude the new fs resizing capabilities at build time
(rather than run time) if the necessary libblkid features
are not available.  When excluded, all fs resizing options
are translated to resize_fsadm.  Accessing the new
features now requires rebuilding lvm if libblkid is
upgraded.
---
 tools/lvresize.c | 32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index bba8ee26c..f3cee8322 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -15,6 +15,8 @@
 
 #include "tools.h"
 
+#include <blkid/blkid.h>
+
 static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 {
 	const char *type_str = arg_str_value(cmd, type_ARG, NULL);
@@ -96,6 +98,12 @@ static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 			return 0;
 		}
 
+#ifdef BLKID_SUBLKS_FSINFO
+		/*
+		 * When the libblkid fs info feature is available, use the
+		 * the newer fs resizing capabability unless the older
+		 * fsadm-based resizing is requested with --fs resize_fsadm.
+		 */
 		if ((str = arg_str_value(cmd, fs_ARG, NULL))) {
 			if (!strcmp(str, "checksize") ||
 			    !strcmp(str, "resize") ||
@@ -123,7 +131,29 @@ static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 			 */
 			strncpy(lp->fsopt, "checksize", sizeof(lp->fsopt)-1);
 		}
-
+#else
+		/*
+		 * When the libblkid fs info feature is not available we can only
+		 * use fsadm, so --resizefs, --fs resize, --fs resize_fsadm
+		 * all translate to resize_fsadm.
+		 */
+		if ((str = arg_str_value(cmd, fs_ARG, NULL))) {
+			if (!strcmp(str, "resize")) {
+				log_warn("Using fsadm for file system handling (resize_fsadm).");
+				strcpy(lp->fsopt, "resize_fsadm");
+			} else if (!strcmp(str, "resize_fsadm")) {
+				strcpy(lp->fsopt, "resize_fsadm");
+			} else if (!strcmp(str, "ignore")) {
+				log_warn("Ignoring unsupported --fs ignore with fsadm resizing.");
+			} else {
+				log_error("Unknown --fs value.");
+				return 0;
+			}
+		} else if (arg_is_set(cmd, resizefs_ARG)) {
+			/* --resizefs alone equates to --fs resize_fsadm */
+			strcpy(lp->fsopt, "resize_fsadm");
+		}
+#endif
 		if (lp->fsopt[0])
 			lp->nofsck = arg_is_set(cmd, nofsck_ARG);
 

