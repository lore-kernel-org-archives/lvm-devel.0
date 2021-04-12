From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:47 +0000 (GMT)
Subject: main - man-generator: spaces
Message-ID: <20210412075547.8F97439FCC77@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53fa1582d97713f33364e5f77c51ab412762e295
Commit:        53fa1582d97713f33364e5f77c51ab412762e295
Parent:        e01ce8e2aeeb08d7f08d99976fa01635d7c3bfa5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 11 20:10:21 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

man-generator: spaces

---
 tools/command.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index a81105b96..52acc70a5 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -128,7 +128,7 @@ static inline int dumptype_arg(struct cmd_context *cmd __attribute__((unused)),
 #define CACHE_VGMETADATA        0x00000001
 #define PERMITTED_READ_ONLY     0x00000002
 #define ALL_VGS_IS_DEFAULT      0x00000004
-#define ENABLE_ALL_DEVS         0x00000008      
+#define ENABLE_ALL_DEVS         0x00000008
 #define ALLOW_UUID_AS_NAME      0x00000010
 #define LOCKD_VG_SH             0x00000020
 #define NO_METADATA_PROCESSING  0x00000040
@@ -709,7 +709,6 @@ static void _set_pos_def(struct command *cmd, char *str, struct arg_def *def)
  * Save an option arg in a struct arg_def.
  * Parse str for anything that can follow --option.
  */
-
 static void _set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char *str, struct arg_def *def)
 {
 	char *argv[MAX_LINE_ARGC];
@@ -767,7 +766,6 @@ static void _set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char
 				def->flags |= ARG_DEF_FLAG_NEW_LV;
 			else if (val_enum == vg_VAL)
 				def->flags |= ARG_DEF_FLAG_NEW_VG;
-				
 		}
 	}
 }
@@ -1120,7 +1118,6 @@ static void _add_required_opt_line(struct cmd_context *cmdtool, struct command *
  * and flag CMD_FLAG_ANY_REQUIRED_OPT is set on the cmd indicating
  * this special case.
  */
- 
 static void _include_required_opt_args(struct cmd_context *cmdtool, struct command *cmd, char *str)
 {
 	char *oo_line;


