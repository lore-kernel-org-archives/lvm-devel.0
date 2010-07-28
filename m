From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:16:00 +0200
Subject: [PATCH 14/14] Proposal of different check for udev dir
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <055c01a96f6775c4fe3372c0ac64538f275d2b0d.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is rather test code to check differently for 'udev' dir usage.
Upstream implementation doesn't allow to use directories like
/dev/shm as normal /tmp dirs as it thinks it starts with /dev so
it is udev 'dev' dir.

Note - few different approaches are here - my prefered version
is the one in dmsetup #if 1

New code allows only  'devdir' or 'devdir/' and simplifies code around.

Also as this code seems to be needed for  dmsetup & lvm - it should be
probably moved as a dm library function usable by both.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/dmsetup.c    |   26 +++++++++++++++++++++++---
 tools/lvmcmdline.c |    4 +++-
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 2af9c28..3be96b4 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -978,11 +978,30 @@ static int _set_up_udev_support(const char *dev_dir)
 	 * races between udev and libdevmapper but only in case udev "dev path"
 	 * is the same as "dev path" used by libdevmapper.
 	 */
-
 	/* There's always a slash at the end of dev_dir. But check udev_dev_dir! */
-	if (udev_dev_dir[udev_dev_dir_len - 1] != '/')
+#if 1
+	if ((strncmp(dev_dir, udev_dev_dir, udev_dev_dir_len) == 0) &&
+	    (dev_dir[udev_dev_dir_len] == '\0' ||
+	     (dev_dir[udev_dev_dir_len] == '/' &&
+	      dev_dir[udev_dev_dir_len + 1] == '\0'))) {
+		_udev_only = _udev_cookie;
+	} else {
+		log_debug("The path %s used for creating device nodes that is "
+			  "set via DM_DEV_DIR environment variable differs from "
+			  "the path %s that is used by udev. All warnings "
+			  "about udev not working correctly while processing "
+			  "particular nodes will be suppressed. These nodes "
+			  "and symlinks will be managed in each directory "
+			  "separately.", dev_dir, udev_dev_dir);
+		dm_udev_set_checking(0);
+		_udev_only = 0;
+	}
+#else
+	if (udev_dev_dir_len > 0 &&
+	    udev_dev_dir[udev_dev_dir_len - 1] != '/' &&
+	    strlen(dev_dir) == (udev_dev_dir_len + 1)) {
 		dirs_diff = strncmp(dev_dir, udev_dev_dir, udev_dev_dir_len);
-	else
+	} else
 		dirs_diff = strcmp(dev_dir, udev_dev_dir);
 
 	_udev_only = _udev_cookie && !dirs_diff;
@@ -997,6 +1016,7 @@ static int _set_up_udev_support(const char *dev_dir)
 			  "separately.", dev_dir, udev_dev_dir);
 		dm_udev_set_checking(0);
 	}
+#endif
 
 	udev_unref(udev);
 	return 1;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6c66fab..7a29e02 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -945,7 +945,9 @@ static int _set_udev_checking(struct cmd_context *cmd)
 	udev_dev_dir_len = strlen(udev_dev_dir);
 
 	/* There's always a slash at the end of dev_dir. But check udev_dev_dir! */
-	if (udev_dev_dir[udev_dev_dir_len - 1] != '/')
+	if (strlen(cmd->dev_dir) > udev_dev_dir_len)
+		dirs_diff = 1;
+	else if (udev_dev_dir[udev_dev_dir_len - 1] != '/')
 		dirs_diff = strncmp(cmd->dev_dir, udev_dev_dir,
 				    udev_dev_dir_len);
 	else
-- 
1.7.2


