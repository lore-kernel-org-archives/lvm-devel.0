From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  2 Apr 2013 13:18:24 +0000 (UTC)
Subject: master - cmdline: add arg_long_option_name
Message-ID: <20130402131824.99F5D208D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b57b394ebbb4b4078d532318110cff60e38035d3
Commit:        b57b394ebbb4b4078d532318110cff60e38035d3
Parent:        2edf488b3844a067bcdfe8f8efdf1a086c52a5cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 22 20:20:33 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 2 15:16:53 2013 +0200

cmdline: add arg_long_option_name

Add simple function to return long_name string option for given arg.
---
 tools/lvmcmdline.c |    5 +++++
 tools/tools.h      |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c7820e0..c69d20d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -73,6 +73,11 @@ unsigned grouped_arg_is_set(const struct arg_values *av, int a)
 	return grouped_arg_count(av, a) ? 1 : 0;
 }
 
+const char *arg_long_option_name(int a)
+{
+	return _cmdline.arg_props[a].long_arg;
+}
+
 const char *arg_value(struct cmd_context *cmd, int a)
 {
 	return cmd->arg_values[a].value;
diff --git a/tools/tools.h b/tools/tools.h
index 673e40b..15d1f84 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -163,6 +163,7 @@ int major_minor_valid(const struct cmd_context * cmd, const struct format_type *
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
 unsigned arg_is_set(const struct cmd_context *cmd, int a);
+const char *arg_long_option_name(int a);
 const char *arg_value(struct cmd_context *cmd, int a);
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 


