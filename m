From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:22 +0000 (UTC)
Subject: master - toollib: new arg list functions
Message-ID: <20141024144022.4128E61079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fc403b0fc5c7fffec4d7864433d0db3c139995c
Commit:        2fc403b0fc5c7fffec4d7864433d0db3c139995c
Parent:        fd1aa7fd5a1ccd7ebcf3446988110ad5c16fddc7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 15 15:06:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

toollib: new arg list functions

Check for negative arg list:
arg_from_list_is_negative()

Check for zero arg in list:
arg_from_list_is_zero()
---
 tools/lvmcmdline.c |   35 +++++++++++++++++++++++++++++++++++
 tools/tools.h      |    2 ++
 2 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4c61332..6e13679 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -127,6 +127,41 @@ int arg_outside_list_is_set(const struct cmd_context *cmd, const char *err_found
 	return 0;
 }
 
+int arg_from_list_is_negative(const struct cmd_context *cmd, const char *err_found, ...)
+{
+	int arg, ret = 0;
+	va_list ap;
+
+	va_start(ap, err_found);
+	while ((arg = va_arg(ap, int)) != -1)
+		if (arg_sign_value(cmd, arg, SIGN_NONE) == SIGN_MINUS) {
+			if (err_found)
+				log_error("%s %s.", arg_long_option_name(arg), err_found);
+			ret = 1;
+		}
+	va_end(ap);
+
+	return ret;
+}
+
+int arg_from_list_is_zero(const struct cmd_context *cmd, const char *err_found, ...)
+{
+	int arg, ret = 0;
+	va_list ap;
+
+	va_start(ap, err_found);
+	while ((arg = va_arg(ap, int)) != -1)
+		if (arg_is_set(cmd, arg) &&
+		    !arg_int_value(cmd, arg, 0)) {
+			if (err_found)
+				log_error("%s %s.", arg_long_option_name(arg), err_found);
+			ret = 1;
+		}
+	va_end(ap);
+
+	return ret;
+}
+
 unsigned grouped_arg_is_set(const struct arg_values *av, int a)
 {
 	return grouped_arg_count(av, a) ? 1 : 0;
diff --git a/tools/tools.h b/tools/tools.h
index 5fa1ab6..75c3eaa 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -148,6 +148,8 @@ unsigned arg_count(const struct cmd_context *cmd, int a);
 unsigned arg_is_set(const struct cmd_context *cmd, int a);
 int arg_from_list_is_set(const struct cmd_context *cmd, const char *err_found, ...);
 int arg_outside_list_is_set(const struct cmd_context *cmd, const char *err_found, ...);
+int arg_from_list_is_negative(const struct cmd_context *cmd, const char *err_found, ...);
+int arg_from_list_is_zero(const struct cmd_context *cmd, const char *err_found, ...);
 const char *arg_long_option_name(int a);
 const char *arg_value(const struct cmd_context *cmd, int a);
 const char *arg_str_value(const struct cmd_context *cmd, int a, const char *def);


