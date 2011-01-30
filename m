From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:24 +0100
Subject: [PATCH 01/24] Add find_config_tree_int64 function
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <9b49b37c91243350f0aaa9f57a6f550695ae5054.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add function for reading 64bit ints.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/config.c |    6 ++++++
 lib/config/config.h |    2 ++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index ffa9fd6..237c610 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1049,6 +1049,12 @@ int find_config_tree_int(struct cmd_context *cmd, const char *path,
 	return (int) _find_config_int64(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, (int64_t) fail);
 }
 
+int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path, int64_t fail)
+{
+	return _find_config_int64(cmd->cft_override ? cmd->cft_override->root : NULL,
+				  cmd->cft->root, path, fail);
+}
+
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
 			     float fail)
 {
diff --git a/lib/config/config.h b/lib/config/config.h
index f70deb0..ae0c6e6 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -95,6 +95,8 @@ const char *find_config_tree_str(struct cmd_context *cmd,
 				 const char *path, const char *fail);
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
 			 int fail);
+int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path,
+			     int64_t fail);
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
 			     float fail);
 
-- 
1.7.3.5


