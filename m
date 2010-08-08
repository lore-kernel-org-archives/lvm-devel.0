From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:27 +0200
Subject: [PATCH 15/25] Replicator: add new command option read functions
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <c629d24b7e55bf135fa142b17318b3fe9ebd0936.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

site_arg - reads name of the site.
sitepolicy_arg - reads site policy.
timeout_arg - reads timeout parameter for fall_hind_timeout.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvmcmdline.c |   71 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/tools.h      |    3 ++
 2 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 54169ad..fa63fa0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -473,6 +473,77 @@ int readahead_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a
 	return 1;
 }
 
+int site_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+{
+	if (!validate_name(a->value)) {
+		log_error("Invalid site name.");
+		return 0;
+	}
+
+	return 1;
+}
+
+int sitepolicy_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+{
+	struct replicator_site rsite;
+
+	if (!replicator_site_set_policy(&rsite, a->value)) {
+		log_error("Invalid site policy %s.", a->value);
+		return 0;
+	}
+
+	a->ui_value = rsite.policy;
+
+	return 1;
+}
+
+/**
+ * Parsing time string in form:   hh:mm:sec
+ * Supported is also format like 3245:34  ->  3245 minutes and 34 seconds
+ * Max supported time value is less then 10000h
+ */
+int timeout_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+{
+	const char *p = a->value;
+	unsigned hours = 0, mins = 0, secs = 0;
+	unsigned idx = 0;
+
+	while (*p) {
+		if (isdigit(*p)) {
+			secs = secs * 10 + *p - '0';
+			if (idx > 0 && secs > 59)
+				goto err;
+			if (secs > 35999999)
+				goto high;
+		} else if (*p == ':') {
+			if (idx++ > 1)
+				goto err;
+			if (idx == 1) {
+				hours = mins;
+				if (hours > 9999)
+					goto high;
+			}
+			mins = secs;
+			if (mins > 599999)
+				goto high;
+			secs = 0;
+		} else
+			goto err;
+		p++;
+	}
+
+	a->ui_value = hours * 3600 + mins * 60 + secs;
+
+	return 1;
+err:
+	log_error("Invalid time string.");
+	return 0;
+
+high:
+	log_error("Parsed time is too high.");
+	return 0;
+}
+
 /*
  * Non-zero, positive integer, "all", or "unmanaged"
  */
diff --git a/tools/tools.h b/tools/tools.h
index e9bc850..ac42276 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -153,6 +153,9 @@ int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
 int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a);
+int site_arg(struct cmd_context *cmd, struct arg *a);
+int sitepolicy_arg(struct cmd_context *cmd, struct arg *a);
+int timeout_arg(struct cmd_context *cmd, struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
-- 
1.7.2.1


