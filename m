From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:25 +0000 (UTC)
Subject: dev-dct-process-latest - cleanup: use const for cmd context
Message-ID: <20140922153925.B6C396092E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=656ba3a744af5548ee0a5983590698aeee3dd326
Commit:        656ba3a744af5548ee0a5983590698aeee3dd326
Parent:        e2312d28ed031dd5c53084b4789763f3c5e6410c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 14:29:12 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:51:31 2014 +0200

cleanup: use const for cmd context

---
 tools/lvmcmdline.c |   18 +++++++++---------
 tools/tools.h      |   20 ++++++++++----------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 04598e2..d90ef91 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -137,12 +137,12 @@ const char *arg_long_option_name(int a)
 	return _cmdline.arg_props[a].long_arg;
 }
 
-const char *arg_value(struct cmd_context *cmd, int a)
+const char *arg_value(const struct cmd_context *cmd, int a)
 {
 	return cmd->arg_values[a].value;
 }
 
-const char *arg_str_value(struct cmd_context *cmd, int a, const char *def)
+const char *arg_str_value(const struct cmd_context *cmd, int a, const char *def)
 {
 	return arg_count(cmd, a) ? cmd->arg_values[a].value : def;
 }
@@ -157,7 +157,7 @@ int32_t grouped_arg_int_value(const struct arg_values *av, int a, const int32_t
 	return grouped_arg_count(av, a) ? av[a].i_value : def;
 }
 
-int32_t first_grouped_arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
+int32_t first_grouped_arg_int_value(const struct cmd_context *cmd, int a, const int32_t def)
 {
 	struct arg_value_group_list *current_group;
 	struct arg_values *av;
@@ -171,23 +171,23 @@ int32_t first_grouped_arg_int_value(struct cmd_context *cmd, int a, const int32_
 	return def;
 }
 
-int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
+int32_t arg_int_value(const struct cmd_context *cmd, int a, const int32_t def)
 {
 	return (_cmdline.arg_props[a].flags & ARG_GROUPABLE) ?
 		first_grouped_arg_int_value(cmd, a, def) : (arg_count(cmd, a) ? cmd->arg_values[a].i_value : def);
 }
 
-uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def)
+uint32_t arg_uint_value(const struct cmd_context *cmd, int a, const uint32_t def)
 {
 	return arg_count(cmd, a) ? cmd->arg_values[a].ui_value : def;
 }
 
-int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def)
+int64_t arg_int64_value(const struct cmd_context *cmd, int a, const int64_t def)
 {
 	return arg_count(cmd, a) ? cmd->arg_values[a].i64_value : def;
 }
 
-uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def)
+uint64_t arg_uint64_value(const struct cmd_context *cmd, int a, const uint64_t def)
 {
 	return arg_count(cmd, a) ? cmd->arg_values[a].ui64_value : def;
 }
@@ -199,12 +199,12 @@ const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
 }
 */
 
-sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def)
+sign_t arg_sign_value(const struct cmd_context *cmd, int a, const sign_t def)
 {
 	return arg_count(cmd, a) ? cmd->arg_values[a].sign : def;
 }
 
-percent_type_t arg_percent_value(struct cmd_context *cmd, int a, const percent_type_t def)
+percent_type_t arg_percent_value(const struct cmd_context *cmd, int a, const percent_type_t def)
 {
 	return arg_count(cmd, a) ? cmd->arg_values[a].percent : def;
 }
diff --git a/tools/tools.h b/tools/tools.h
index beb1671..51c6a4e 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -147,16 +147,16 @@ unsigned arg_is_set(const struct cmd_context *cmd, int a);
 int arg_from_list_is_set(const struct cmd_context *cmd, const char *err_found, ...);
 int arg_outside_list_is_set(const struct cmd_context *cmd, const char *err_found, ...);
 const char *arg_long_option_name(int a);
-const char *arg_value(struct cmd_context *cmd, int a);
-const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);
-int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 
-int32_t first_grouped_arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 
-uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def);
-int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def);
-uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def);
-const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def);
-sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def);
-percent_type_t arg_percent_value(struct cmd_context *cmd, int a, const percent_type_t def);
+const char *arg_value(const struct cmd_context *cmd, int a);
+const char *arg_str_value(const struct cmd_context *cmd, int a, const char *def);
+int32_t arg_int_value(const struct cmd_context *cmd, int a, const int32_t def);
+int32_t first_grouped_arg_int_value(const struct cmd_context *cmd, int a, const int32_t def);
+uint32_t arg_uint_value(const struct cmd_context *cmd, int a, const uint32_t def);
+int64_t arg_int64_value(const struct cmd_context *cmd, int a, const int64_t def);
+uint64_t arg_uint64_value(const struct cmd_context *cmd, int a, const uint64_t def);
+const void *arg_ptr_value(const struct cmd_context *cmd, int a, const void *def);
+sign_t arg_sign_value(const struct cmd_context *cmd, int a, const sign_t def);
+percent_type_t arg_percent_value(const struct cmd_context *cmd, int a, const percent_type_t def);
 int arg_count_increment(struct cmd_context *cmd, int a);
 
 unsigned grouped_arg_count(const struct arg_values *av, int a);


