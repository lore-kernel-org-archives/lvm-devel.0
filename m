From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:39 +0000 (UTC)
Subject: master - lvmcmdline: return 0/NULL if cmd->arg_values not set and arg_count/grouped_arg_count/arg_value called
Message-ID: <20160809173939.75FC76023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5649834f7d62b9cba3b06c1b5d0dd425978f3ad2
Commit:        5649834f7d62b9cba3b06c1b5d0dd425978f3ad2
Parent:        1fde4bf4d08cbf579dbbe5eb08661eac67eb68f7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 09:32:05 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:24:45 2016 +0200

lvmcmdline: return 0/NULL if cmd->arg_values not set and arg_count/grouped_arg_count/arg_value called

We may call arg_count/grouped_arg_count/arg_value soon enough that
cmd->arg_values is not set yet.

Normally, when running a command, we execute lvm_run_command which in
turn calls _process_command_line to allocate and parse the command line
values and stores them in cmd->arg_values.

However, if we run lvm shell, this one doesn't accept any command line
options and we parse the command line for each command that is executed
within the lvm shell then. If we used any code that tries to access
cmd->arg_values through any of the the arg handling functions too
early, we could end up with a segfault due to uninitialized (NULL)
cmd->arg_values.

This patch just saves extra checks in all the code where arg handling
may be called too early so that the cmd->arg_values is not set up yet.
This does not apply to any of existing code, but subsequent patches
will need that.
---
 tools/lvmcmdline.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 629fb14..81118c1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -63,12 +63,12 @@ static struct cmdline_context _cmdline;
 /* Command line args */
 unsigned arg_count(const struct cmd_context *cmd, int a)
 {
-	return cmd->arg_values[a].count;
+	return cmd->arg_values ? cmd->arg_values[a].count : 0;
 }
 
 unsigned grouped_arg_count(const struct arg_values *av, int a)
 {
-	return av[a].count;
+	return av ? av[a].count : 0;
 }
 
 unsigned arg_is_set(const struct cmd_context *cmd, int a)
@@ -182,7 +182,7 @@ const char *arg_long_option_name(int a)
 
 const char *arg_value(const struct cmd_context *cmd, int a)
 {
-	return cmd->arg_values[a].value;
+	return cmd->arg_values ? cmd->arg_values[a].value : NULL;
 }
 
 const char *arg_str_value(const struct cmd_context *cmd, int a, const char *def)


