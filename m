From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:21 +0100
Subject: [PATCH 17/29] Optimize second call to strchr with same parameters
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <da11b09033bc753792a43d6f4d2ce98826c7ae21.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add tempory char* to keep result of strchr call.
Make also static analysis happier as lv_name is now tested for nonnull.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 9af1630..f6ba45b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -214,6 +214,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 		for (; opt < argc; opt++) {
 			const char *lv_name = argv[opt];
+			const char *tmp_lv_name;
 			char *vgname_def;
 			unsigned dev_dir_found = 0;
 
@@ -246,9 +247,9 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 				continue;
 			}
 			lv_name = vgname;
-			if (strchr(vgname, '/')) {
+			if ((tmp_lv_name = strchr(vgname, '/'))) {
 				/* Must be an LV */
-				lv_name = strchr(vgname, '/');
+				lv_name = tmp_lv_name;
 				while (*lv_name == '/')
 					lv_name++;
 				if (!(vgname = extract_vgname(cmd, vgname))) {
-- 
1.7.3.2


