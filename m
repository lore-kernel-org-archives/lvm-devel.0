From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Jul 2017 16:12:19 -0400
Subject: master - commands: expand comment on configuring option vals
Message-ID: <201707242012.v6OKCJ11004047@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca71ad0d5025d2d01eb9666368c1da7db3c9c7ce
Commit:        ca71ad0d5025d2d01eb9666368c1da7db3c9c7ce
Parent:        2938fa541aa66da66e32b9ea4b796dbedcf5062e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 20 16:54:40 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 24 14:12:08 2017 -0500

commands: expand comment on configuring option vals

---
 tools/command.c |   48 ++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 38 insertions(+), 10 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index b4e5e76..52a3766 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1575,17 +1575,45 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 }
 
 /*
- * This does not change the option vals in the cmd defs in commands[]
- * which are used when printing help/man output.
+ * The opt_names[] table describes each option.  It is indexed by the
+ * option typedef, e.g. size_ARG.  The size_ARG entry specifies the
+ * option name, e.g. --size, and the kind of value it accepts,
+ * e.g. sizemb_VAL.
  *
- * The specific val types for each command are specified in
- * command-lines.in/commands[], and those are used for printing
- * man/help.  But the opt_names[] array for each option is global
- * and has no command name context.  So the opt_names[] array always
- * specifies a non-signed val, e.g. sizemb_VAL, extents_VAL.  The
- * opt_names[] array is used by run time processing, and for part
- * of the help/man output.  This adjusts the opt_names[] val types
- * according to the command being run.
+ * The val_names[] table describes each option value type.  It is indexed by
+ * the value typedef, e.g. sizemb_VAL.  The sizemb_VAL entry specifies the
+ * function used to parse the value, e.g. size_mb_arg(), the string used to
+ * refer to the value in the command-lines.in specifications, e.g. SizeMB,
+ * and how the value should be displayed in a man page, e.g. Size[m|UNIT].
+ *
+ * A problem is that these tables are independent of a particular command
+ * (they are created at build time), but different commands accept different
+ * types of values for the same option, e.g. one command will accept
+ * signed size values (ssizemb_VAL), while another does not accept a signed
+ * number, (sizemb_VAL).  This function deals with this problem by tweaking
+ * the opt_names[] table at run time according to the specific command being run.
+ * i.e. it changes size_ARG to accept sizemb_VAL or ssizemb_VAL depending
+ * on the command.
+ *
+ * By default, size_ARG in opt_names[] is set up to accept a standard
+ * sizemb_VAL.  The same is done for other opt_names[] entries that
+ * take different option values.
+ *
+ * This function overrides default opt_names[] entries at run time according
+ * to the command name, adjusting the value types accepted by various options.
+ * So, for lvresize, opt_names[sizemb_VAL] is overriden to accept
+ * the relative (+ or -) value type ssizemb_VAL, instead of the default
+ * sizemb_VAL.  This way, when lvresize processes the --size value, it
+ * will use the ssize_mb_arg() function which accepts relative size values.
+ * When lvcreate processes the --size value, it uses size_mb_arg() which
+ * rejects signed values.
+ *
+ * The command defs in commands[] do not need to be overriden because
+ * the command-lines.in defs have the context of a command, and are
+ * described using the proper value type, e.g. this cmd def already
+ * uses the relative size value: "lvresize --size SSizeMB LV",
+ * so the commands[] entry for the cmd def already references the
+ * correct ssizemb_VAL.
  */
 void configure_command_option_values(const char *name)
 {


