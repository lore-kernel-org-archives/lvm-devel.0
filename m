From: Milan Broz <mbroz@redhat.com>
Date: Tue, 10 Mar 2009 18:41:30 +0100
Subject: [PATCH 3/3] fix metadata backup description for long lived process
Message-ID: <49B6A64A.9070103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix metadata backup description for long lived process.

If backup is run from clvmd (or long lived process),
the *before* and *after* makes no sense, because
commandline is always "clvmd" :-)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format_text/archiver.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index a3efc3e..861d9f6 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -75,27 +75,30 @@ void archive_enable(struct cmd_context *cmd, int flag)
 	cmd->archive_params->enabled = flag;
 }
 
-static char *_build_desc(struct dm_pool *mem, const char *line, int before)
+static char *_build_desc(struct cmd_context *cmd, int before)
 {
-	size_t len = strlen(line) + 32;
+	size_t len = strlen(cmd->cmd_line) + 32;
 	char *buffer;
+	int ret;
 
-	if (!(buffer = dm_pool_zalloc(mem, strlen(line) + 32)))
+	if (!(buffer = dm_pool_zalloc(cmd->mem, strlen(cmd->cmd_line) + 32)))
 		return_NULL;
 
-	if (snprintf(buffer, len,
+	if (cmd->is_long_lived)
+		ret = snprintf(buffer, len, "Created by %s", cmd->cmd_line);
+	else
+		ret = snprintf(buffer, len,
 		     "Created %s executing '%s'",
-		     before ? "*before*" : "*after*", line) < 0)
-		return_NULL;
+		     before ? "*before*" : "*after*", cmd->cmd_line);
 
-	return buffer;
+	return (ret < 0) ? NULL : buffer;
 }
 
 static int __archive(struct volume_group *vg)
 {
 	char *desc;
 
-	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 1)))
+	if (!(desc = _build_desc(vg->cmd, 1)))
 		return_0;
 
 	return archive_vg(vg, vg->cmd->archive_params->dir, desc,
@@ -190,7 +193,7 @@ static int __backup(struct volume_group *vg)
 	char name[PATH_MAX];
 	char *desc;
 
-	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 0)))
+	if (!(desc = _build_desc(vg->cmd, 0)))
 		return_0;
 
 	if (dm_snprintf(name, sizeof(name), "%s/%s",



