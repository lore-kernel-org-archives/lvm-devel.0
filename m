From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:48 +0200
Subject: [PATCH 14/22] Replicator: add new command option read functions
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <32bd60e3aa9dc3d04197da56cfa672e0940064ea.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

site_arg - reads name of the site.
sitemode_arg - reads site mode.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvmcmdline.c |   24 ++++++++++++++++++++++++
 tools/tools.h      |    2 ++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 8ff74ac..7d55e48 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -473,6 +473,30 @@ int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 	return 1;
 }
 
+int site_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+{
+	if (!validate_name(a->value)) {
+		log_error("Invalid site name.");
+		return 0;
+	}
+
+	return 1;
+}
+
+int sitemode_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+{
+	struct replicator_site rsite;
+
+	if (!replicator_site_set_op_mode(&rsite, a->value)) {
+		log_error("Invalid site mode %s.", a->value);
+		return 0;
+	}
+
+	a->ui_value = rsite.op_mode;
+
+	return 1;
+}
+
 /*
  * Non-zero, positive integer, "all", or "unmanaged"
  */
diff --git a/tools/tools.h b/tools/tools.h
index 2e06fc2..3104d0a 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -153,6 +153,8 @@ int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
 int metadatacopies_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a);
+int site_arg(struct cmd_context *cmd, struct arg *a);
+int sitemode_arg(struct cmd_context *cmd, struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
-- 
1.7.1.1


