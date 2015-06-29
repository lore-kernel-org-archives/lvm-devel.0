From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 14:18:11 +0000 (UTC)
Subject: master - cleanup: time: error out on incorrect time_format and indentation in config_settings.h
Message-ID: <20150629141811.2E41960D2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77f0e7a450dc2bc3e42bb4854e1032873d661c58
Commit:        77f0e7a450dc2bc3e42bb4854e1032873d661c58
Parent:        621398ebb79760d6e86f8264e4198946d59e6522
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 29 16:16:58 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 16:17:33 2015 +0200

cleanup: time: error out on incorrect time_format and indentation in config_settings.h

---
 conf/example.conf.in         |    7 ++++---
 lib/commands/toolcontext.c   |    7 ++++---
 lib/config/config_settings.h |    8 ++++----
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 41b9702..4520162 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1416,7 +1416,7 @@ activation {
 	# Format specification is a string which may contain special character
 	# sequences and ordinary character sequences. Ordinary character sequences
 	# are copied verbatim. Each special character sequence is introduced by '%'
-	# character and such sequence is then substitued with a value as described below:
+	# character and such sequence is then substituted with a value as described below:
 	# %a     The abbreviated name of the day of the week according to the
 	#        current locale.
 	# %A     The full name of the day of the week according to the current locale.
@@ -1480,8 +1480,9 @@ activation {
 	# %y     The year as a decimal number without a century (range 00 to 99). (alt E, alt O)
 	# %Y     The year as a decimal number including the century. (alt E)
 	# %z     The +hhmm or -hhmm numeric timezone (that is, the hour and minute
-	#        offset from UTC).%Z     The timezone name or abbreviation.
-	# %%    A literal '%' character.
+	#        offset from UTC).
+	# %Z     The timezone name or abbreviation.
+	# %%     A literal '%' character.
 	# time_format = "%Y-%m-%d %T %z"
 
 	# Configuration option report/devtypes_sort.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 09c14a3..4265954 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -460,8 +460,8 @@ static const char *_set_time_format(struct cmd_context *cmd)
 
 	return tf;
 bad:
-	log_error("Incorrect time format specified. Using default time format instead.");
-	return DEFAULT_TIME_FORMAT;
+	log_error("Invalid time format \"%s\" supplied.", tf);
+	return NULL;
 }
 
 int process_profilable_config(struct cmd_context *cmd)
@@ -477,7 +477,8 @@ int process_profilable_config(struct cmd_context *cmd)
 	cmd->report_binary_values_as_numeric = find_config_tree_bool(cmd, report_binary_values_as_numeric_CFG, NULL);
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 	cmd->report_list_item_separator = find_config_tree_str(cmd, report_list_item_separator_CFG, NULL);
-	cmd->time_format = _set_time_format(cmd);
+	if (!(cmd->time_format = _set_time_format(cmd)))
+		return 0;
 
 	return 1;
 }
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index ac68906..fb05b85 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -81,7 +81,7 @@
  *                             (see also lvmconfig ... --withversions)
  *
  * unconfigured_default_value: Unconfigured default value used as a default value which is
- *                             in "@...@" form and which is then substitued with concrete value
+ *                             in "@...@" form and which is then substituted with concrete value
  *                             while running configure.
  *                             (see also 'lvmconfig --type default --unconfigured')
  *
@@ -1362,7 +1362,7 @@ cfg(report_time_format_CFG, "time_format", report_CFG_SECTION, CFG_PROFILABLE |
 	"Format specification is a string which may contain special character\n"
 	"sequences and ordinary character sequences. Ordinary character sequences\n"
 	"are copied verbatim. Each special character sequence is introduced by \'%\'\n"
-	"character and such sequence is then substitued with a value as described below:\n"
+	"character and such sequence is then substituted with a value as described below:\n"
 	"\%a     The abbreviated name of the day of the week according to the\n"
 	"       current locale.\n"
 	"\%A     The full name of the day of the week according to the current locale.\n"
@@ -1426,9 +1426,9 @@ cfg(report_time_format_CFG, "time_format", report_CFG_SECTION, CFG_PROFILABLE |
 	"\%y     The year as a decimal number without a century (range 00 to 99). (alt E, alt O)\n"
 	"\%Y     The year as a decimal number including the century. (alt E)\n"
 	"\%z     The +hhmm or -hhmm numeric timezone (that is, the hour and minute\n"
-	"       offset from UTC)."
+	"       offset from UTC).\n"
 	"\%Z     The timezone name or abbreviation.\n"
-	"\%\%    A literal '\%' character.\n")
+	"\%\%     A literal '\%' character.\n")
 
 cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'lvm devtypes' command.\n"


