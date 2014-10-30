From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:43 +0000 (UTC)
Subject: master - lvmcmdline: support size_mb_arg_with_percent
Message-ID: <20141030230043.280DE60DD0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=464f3b8abd03633ff5dd2c5fe5585d921af8931f
Commit:        464f3b8abd03633ff5dd2c5fe5585d921af8931f
Parent:        519fbe71e46c747a254bc200ea93396591e1a1a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 14:52:37 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

lvmcmdline: support size_mb_arg_with_percent

New size_mb_arg_with_percent is able to read  size_mb_arg
but also it's able to read % values.

Percent parsing is share with int_arg_with_sign_and_percent.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |   66 +++++++++++++++++++++++++++++++++++++---------------
 tools/tools.h      |    1 +
 3 files changed, 49 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a8ea15f..bb8cd8d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Introduce size_mb_arg_with_percent() for advanced size arg reading.
   Add extra support for '.' as decimal point in size args.
   Configurable support for creation of sparse volumes with thin-pools.
   Update and correct lvcreate and lvcovert man pages.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 33c0045..1d3e993 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -384,8 +384,32 @@ static int _get_int_arg(struct arg_values *av, char **ptr)
 	return 1;
 }
 
+static int _get_percent_arg(struct arg_values *av, const char *ptr)
+{
+	if (!strcasecmp(ptr, "V") || !strcasecmp(ptr, "VG"))
+		av->percent = PERCENT_VG;
+	else if (!strcasecmp(ptr, "L") || !strcasecmp(ptr, "LV"))
+		av->percent = PERCENT_LV;
+	else if (!strcasecmp(ptr, "P") || !strcasecmp(ptr, "PV") ||
+		 !strcasecmp(ptr, "PVS"))
+		av->percent = PERCENT_PVS;
+	else if (!strcasecmp(ptr, "F") || !strcasecmp(ptr, "FR") ||
+		 !strcasecmp(ptr, "FREE"))
+		av->percent = PERCENT_FREE;
+	else if (!strcasecmp(ptr, "O") || !strcasecmp(ptr, "OR") ||
+		 !strcasecmp(ptr, "ORIGIN"))
+		av->percent = PERCENT_ORIGIN;
+	else {
+		log_error("Specified %%%s is unknown.", ptr);
+		return 0;
+	}
+
+	return 1;
+}
+
 /* Size stored in sectors */
-static int _size_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av, int factor)
+static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
+		     struct arg_values *av, int factor, int percent)
 {
 	char *ptr;
 	int i;
@@ -429,7 +453,14 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)), struct arg
 	if (ptr == val)
 		return 0;
 
-	if (*ptr) {
+	if (percent && *ptr == '%') {
+		if (!_get_percent_arg(av, ++ptr))
+			return_0;
+		if ((uint64_t) v >= UINT32_MAX) {
+			log_error("Percentage is too big (>=%d%%).", UINT32_MAX);
+			return 0;
+		}
+	} else if (*ptr) {
 		for (i = strlen(suffixes) - 1; i >= 0; i--)
 			if (suffixes[i] == tolower((int) *ptr))
 				break;
@@ -474,12 +505,17 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)), struct arg
 
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return _size_arg(cmd, av, 2);
+	return _size_arg(cmd, av, 2, 0);
 }
 
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return _size_arg(cmd, av, 2048);
+	return _size_arg(cmd, av, 2048, 0);
+}
+
+int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av)
+{
+	return _size_arg(cmd, av, 2048, 1);
 }
 
 int int_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
@@ -516,21 +552,13 @@ int int_arg_with_sign_and_percent(struct cmd_context *cmd __attribute__((unused)
 	if (*ptr++ != '%')
 		return 0;
 
-	if (!strcasecmp(ptr, "V") || !strcasecmp(ptr, "VG"))
-		av->percent = PERCENT_VG;
-	else if (!strcasecmp(ptr, "L") || !strcasecmp(ptr, "LV"))
-		av->percent = PERCENT_LV;
-	else if (!strcasecmp(ptr, "P") || !strcasecmp(ptr, "PV") ||
-		 !strcasecmp(ptr, "PVS"))
-		av->percent = PERCENT_PVS;
-	else if (!strcasecmp(ptr, "F") || !strcasecmp(ptr, "FR") ||
-		 !strcasecmp(ptr, "FREE"))
-		av->percent = PERCENT_FREE;
-	else if (!strcasecmp(ptr, "O") || !strcasecmp(ptr, "OR") ||
-		 !strcasecmp(ptr, "ORIGIN"))
-		av->percent = PERCENT_ORIGIN;
-	else
+	if (!_get_percent_arg(av, ptr))
+		return_0;
+
+	if (av->ui64_value >= UINT32_MAX) {
+		log_error("Percentage is too big (>=%d%%).", UINT32_MAX);
 		return 0;
+	}
 
 	return 1;
 }
@@ -613,7 +641,7 @@ int readahead_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_va
 		return 1;
 	}
 
-	if (!_size_arg(cmd, av, 1))
+	if (!_size_arg(cmd, av, 1, 0))
 		return 0;
 
 	if (av->sign == SIGN_MINUS)
diff --git a/tools/tools.h b/tools/tools.h
index 5a5d729..2196dba 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -129,6 +129,7 @@ int discards_arg(struct cmd_context *cmd, struct arg_values *av);
 int mirrorlog_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
+int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av);
 int int_arg_with_sign_and_percent(struct cmd_context *cmd, struct arg_values *av);


