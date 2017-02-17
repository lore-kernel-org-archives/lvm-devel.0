From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Feb 2017 12:25:33 +0000 (UTC)
Subject: master - commands: use dm_strncpy
Message-ID: <20170217122533.9F05760DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=582a272b3f401e1bb6eafaa52d0ed1d318d04a9f
Commit:        582a272b3f401e1bb6eafaa52d0ed1d318d04a9f
Parent:        80b717af0c1c0602537a6e4d5fad76e09733f028
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 09:59:29 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 13:11:33 2017 +0100

commands: use dm_strncpy

Easier code using dm_strncpy() an dm_snprintf().
---
 tools/command.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index f1b9d8e..e5a4640 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -330,13 +330,13 @@ static char *split_line(char *buf, int *argc, char **argv, char sep)
 
 static int val_str_to_num(char *str)
 {
-	char name[32] = { 0 };
+	char name[32];
 	char *new;
 	int i;
 
 	/* compare the name before any suffix like _new or _<lvtype> */
 
-	strncpy(name, str, 31);
+	dm_strncpy(name, str, sizeof(name));
 	if ((new = strstr(name, "_")))
 		*new = '\0';
 
@@ -757,12 +757,8 @@ static void append_oo_definition_line(struct command *cmd, const char *new_line)
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
-	memset(line, 0, len);
-
-	strcat(line, old_line);
-	strcat(line, " ");
-	strcat(line, new_line);
 
+	(void) dm_snprintf(line, len, "%s %s", old_line, new_line);
 	dm_free(oo->line);
 	oo->line = line;
 }
@@ -778,8 +774,7 @@ static char *get_oo_line(const char *str)
 	char str2[OO_NAME_LEN];
 	int i;
 
-	memset(str2, 0, sizeof(str2));
-	strncpy(str2, str, OO_NAME_LEN-1);
+	dm_strncpy(str2, str, sizeof(str2));
 	if ((end = strstr(str2, ":")))
 		*end = '\0';
 	if ((end = strstr(str2, ",")))


