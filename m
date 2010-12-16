From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:27 +0100
Subject: [PATCH 19/20] Remove unused dev_dir_provided
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <355b55070dabdeb0fd266e946f169d3a001c9ea2.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'dev_dir_provided' is unused - remove it.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0a1a8d4..f76aacd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -842,7 +842,6 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 	const char *vg_name = lv_name;
 	char *st;
 	char *dev_dir = cmd->dev_dir;
-	int dev_dir_provided = 0;
 
 	/* Path supplied? */
 	if (vg_name && strchr(vg_name, '/')) {
@@ -854,7 +853,6 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 		}
 		if (!strncmp(vg_name, dev_dir, strlen(dev_dir))) {
 			vg_name += strlen(dev_dir);
-			dev_dir_provided = 1;
 			while (*vg_name == '/')
 				vg_name++;
 		}
-- 
1.7.3.3


