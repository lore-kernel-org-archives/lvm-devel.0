From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:26 +0000 (UTC)
Subject: master - tools: arg_is_any_set and arg_is_only_set
Message-ID: <20140711113426.7166C60D06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1931d1e58e1b7af8251d96ed84694c3ba5c7352e
Commit:        1931d1e58e1b7af8251d96ed84694c3ba5c7352e
Parent:        c0c1ada88eef8e112515f5415dc4dd89b4191214
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 10 22:52:53 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:57:45 2014 +0200

tools: arg_is_any_set and arg_is_only_set

Helpful functions to more easily detect conflicting
set of options.
---
 tools/lvmcmdline.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/tools.h      |    2 +
 2 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index fc51c4a..be7844b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -68,6 +68,61 @@ unsigned arg_is_set(const struct cmd_context *cmd, int a)
 	return arg_count(cmd, a) ? 1 : 0;
 }
 
+int arg_is_any_set(const struct cmd_context *cmd, const char *err, ...)
+{
+	int arg;
+	va_list ap;
+
+	va_start(ap, err);
+	while ((arg = va_arg(ap, int)) != -1 && !arg_count(cmd, arg))
+		/* empty */;
+	va_end(ap);
+
+	if (arg != -1) {
+		log_error("%s %s.", arg_long_option_name(arg), err);
+		return 0;
+	}
+
+	return 1;
+}
+
+int arg_is_only_set(const struct cmd_context *cmd, const char *err, ...)
+{
+	int i, arg;
+	va_list ap;
+
+	for (i = 0; i < ARG_COUNT; ++i) {
+		switch (i) {
+		/* skip common options */
+		case commandprofile_ARG:
+		case config_ARG:
+		case debug_ARG:
+		case driverloaded_ARG:
+		case help2_ARG:
+		case help_ARG:
+		case profile_ARG:
+		case quiet_ARG:
+		case verbose_ARG:
+		case version_ARG:
+		case yes_ARG:
+			continue;
+		}
+		if (!arg_count(cmd, i))
+			continue; /* unset */
+		va_start(ap, err);
+		while (((arg = va_arg(ap, int)) != -1) && (arg != i))
+			/* empty */;
+		va_end(ap);
+
+		if (arg != i) {
+			log_error("Option %s %s.", arg_long_option_name(i), err);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 unsigned grouped_arg_is_set(const struct arg_values *av, int a)
 {
 	return grouped_arg_count(av, a) ? 1 : 0;
diff --git a/tools/tools.h b/tools/tools.h
index 2b09f37..a92845a 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -144,6 +144,8 @@ int major_minor_valid(const struct cmd_context * cmd, const struct format_type *
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
 unsigned arg_is_set(const struct cmd_context *cmd, int a);
+int arg_is_any_set(const struct cmd_context *cmd, const char *err, ...);
+int arg_is_only_set(const struct cmd_context *cmd, const char *err, ...);
 const char *arg_long_option_name(int a);
 const char *arg_value(struct cmd_context *cmd, int a);
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);


