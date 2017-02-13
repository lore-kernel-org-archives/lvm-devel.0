From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:37 +0000 (UTC)
Subject: master - command.h comment tidying
Message-ID: <20170213181037.1B64F6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9d5b8414bb5ead7dbd223606a735497c0c069f9
Commit:        d9d5b8414bb5ead7dbd223606a735497c0c069f9
Parent:        9a0f0c70bf59a5cd07828ff39e5ff04b4a5411ad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 13 14:51:50 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

command.h comment tidying

---
 tools/command.h |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/tools/command.h b/tools/command.h
index e4ce989..d66ec52 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -110,7 +110,6 @@ struct pos_arg {
 };
 
 /*
- *
  * Commands using a given command definition must follow a set
  * of rules.  If a given command+LV matches the conditions in
  * opts/lvt_bits/lvp_bits, then the checks are applied.
@@ -133,10 +132,11 @@ struct cmd_rule {
 	uint32_t rule;			/* RULE_INVALID, RULE_REQUIRE: check values must [not] be true */
 	int opts_count;			/* entries in opts[] */
 	int check_opts_count;		/* entries in check_opts[] */
-
 };
 
 /*
+ * Array sizes
+ *
  * CMD_RO_ARGS needs to accomodate a list of options,
  * of which one is required after which the rest are
  * optional.
@@ -152,8 +152,8 @@ struct cmd_rule {
  * one or more from required_opt_args is required,
  * then the rest are optional.
  */
-#define CMD_FLAG_ONE_REQUIRED_OPT   1
-#define CMD_FLAG_SECONDARY_SYNTAX   2
+#define CMD_FLAG_ONE_REQUIRED_OPT   1  /* lvchange/vgchage require one item from required_opt_args */
+#define CMD_FLAG_SECONDARY_SYNTAX   2  /* allows syntax variants to be suppressed in certain output */
 
 /* a register of the lvm commands */
 struct command {
@@ -197,11 +197,9 @@ struct command {
 	int rp_count;
 	int op_count;
 	int io_count;
-
-	/* used for processing current position */
-	int pos_count;
-
 	int rule_count;
+
+	int pos_count; /* temp counter used by create-command */
 };
 
 #endif


