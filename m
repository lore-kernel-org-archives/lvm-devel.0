From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:26 +0000 (UTC)
Subject: master - refactor: move code detecting report options to a separate function
Message-ID: <20151030145226.11642609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e149fe7fdfd22b496bbd870d19412b0e9f090149
Commit:        e149fe7fdfd22b496bbd870d19412b0e9f090149
Parent:        77605457e7cf550364355b03cb5544b57d3c046d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 20 16:36:11 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

refactor: move code detecting report options to a separate function

---
 tools/reporter.c |   46 +++++++++++++++++++++++++++-------------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 6c93739..4cf099b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -604,13 +604,35 @@ static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
 	}
 }
 
+static int _get_report_options(struct cmd_context *cmd, const char **options)
+{
+	const char *opts;
+	char *str;
+
+	opts = arg_str_value(cmd, options_ARG, "");
+	if (!opts || !*opts) {
+		log_error("Invalid options string: %s", opts);
+		return EINVALID_CMD_LINE;
+	}
+	if (*opts == '+') {
+		if (!(str = dm_pool_alloc(cmd->mem,
+				 strlen(*options) + strlen(opts) + 1))) {
+			log_error("options string allocation failed");
+			return ECMD_FAILED;
+		}
+		(void) sprintf(str, "%s,%s", *options, opts + 1);
+		*options = str;
+	} else
+		*options = opts;
+
+	return ECMD_PROCESSED;
+}
+
 static int _report(struct cmd_context *cmd, int argc, char **argv,
 		   report_type_t report_type)
 {
 	void *report_handle;
 	struct processing_handle handle = {0};
-	const char *opts;
-	char *str;
 	const char *keys = NULL, *options = NULL, *selection = NULL, *separator;
 	int r = ECMD_PROCESSED;
 	int aligned, buffered, headings, field_prefixes, quoted;
@@ -689,23 +711,9 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	/* If -o supplied use it, else use default for report_type */
-	if (arg_count(cmd, options_ARG)) {
-		opts = arg_str_value(cmd, options_ARG, "");
-		if (!opts || !*opts) {
-			log_error("Invalid options string: %s", opts);
-			return EINVALID_CMD_LINE;
-		}
-		if (*opts == '+') {
-			if (!(str = dm_pool_alloc(cmd->mem,
-					 strlen(options) + strlen(opts) + 1))) {
-				log_error("options string allocation failed");
-				return ECMD_FAILED;
-			}
-			(void) sprintf(str, "%s,%s", options, opts + 1);
-			options = str;
-		} else
-			options = opts;
-	}
+	if (arg_count(cmd, options_ARG) &&
+	    ((r = _get_report_options(cmd, &options) != ECMD_PROCESSED)))
+		return r;
 
 	/* -O overrides default sort settings */
 	keys = arg_str_value(cmd, sort_ARG, keys);


