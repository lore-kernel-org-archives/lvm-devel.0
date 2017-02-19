From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:47:02 +0000 (UTC)
Subject: master - cleanup: use const
Message-ID: <20170219234702.804D260563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aff62c74b7b947d19dda7f03e79d0f2437ad4730
Commit:        aff62c74b7b947d19dda7f03e79d0f2437ad4730
Parent:        f16ad760cb828228affd13cb6d701dfb54a5f249
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 18 18:50:22 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 20 00:43:40 2017 +0100

cleanup: use const

---
 tools/command.c    |    4 ++--
 tools/command.h    |    2 +-
 tools/lvmcmdline.c |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 0ec5176..f46fb3d 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1302,8 +1302,8 @@ static void factor_common_options(void)
 
 static int long_name_compare(const void *on1, const void *on2)
 {
-	struct opt_name **optname1 = (void *)on1;
-	struct opt_name **optname2 = (void *)on2;
+	const struct opt_name * const *optname1 = (const void *)on1;
+	const struct opt_name * const *optname2 = (const void *)on2;
 	return strcmp((*optname1)->long_opt + 2, (*optname2)->long_opt + 2);
 }
 
diff --git a/tools/command.h b/tools/command.h
index 95bd797..2d8f628 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -177,7 +177,7 @@ struct command {
 	int command_enum; /* <command_id>_CMD */
 	int command_index; /* position in commands[] */
 
-	struct command_function *functions; /* new style */
+	const struct command_function *functions; /* new style */
 	command_fn fn;                      /* old style */
 
 	unsigned int cmd_flags; /* CMD_FLAG_ */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c304602..e796873 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -109,7 +109,7 @@ static struct cmdline_context _cmdline;
  * to use these functions instead of the old per-command-name function.
  * For now, any command id not included here uses the old command fn.
  */
-struct command_function command_functions[CMD_COUNT] = {
+static const struct command_function command_functions[CMD_COUNT] = {
 	{ lvmconfig_general_CMD, lvmconfig },
 	{ lvchange_properties_CMD, lvchange_properties_cmd },
 	{ lvchange_resync_CMD, lvchange_resync_cmd },
@@ -1112,7 +1112,7 @@ static struct command_name *find_command_name(const char *name)
 	return NULL;
 }
 
-static struct command_function *_find_command_id_function(int command_enum)
+static const struct command_function *_find_command_id_function(int command_enum)
 {
 	int i;
 


