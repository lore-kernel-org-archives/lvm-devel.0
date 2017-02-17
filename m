From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Feb 2017 12:25:31 +0000 (UTC)
Subject: master - commands: cheap optimisation for parser
Message-ID: <20170217122531.704C060DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80b717af0c1c0602537a6e4d5fad76e09733f028
Commit:        80b717af0c1c0602537a6e4d5fad76e09733f028
Parent:        298b11aed1f1517329dc6e5ead661855b1abfb05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 11:52:37 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 13:00:05 2017 +0100

commands: cheap optimisation for parser

Some low-hanging fruits to cut of signification number of strcmp calls.
---
 tools/command.c |   38 ++++++++++++++++++--------------------
 1 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 5b31b4e..f1b9d8e 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -495,31 +495,32 @@ static struct command_name *find_command_name(const char *name)
 {
 	int i;
 
+	if (!islower(name[0]))
+		return NULL; /* Commands starts with lower-case */
+
 	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
 		if (!command_names[i].name)
 			break;
 		if (!strcmp(command_names[i].name, name))
 			return &command_names[i];
 	}
+
 	return NULL;
 }
 
 static const char *is_command_name(char *str)
 {
-	int i;
+	const struct command_name *c;
+
+	if ((c = find_command_name(str)))
+		return c->name;
 
-	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
-		if (!command_names[i].name)
-			break;
-		if (!strcmp(command_names[i].name, str))
-			return command_names[i].name;
-	}
 	return NULL;
 }
 
 static int is_opt_name(char *str)
 {
-	if (!strncmp(str, "--", 2))
+	if ((str[0] == '-') && (str[1] == '-'))
 		return 1;
 
 	if ((str[0] == '-') && (str[1] != '-'))
@@ -535,18 +536,15 @@ static int is_opt_name(char *str)
 
 static int is_pos_name(char *str)
 {
-	if (!strncmp(str, "VG", 2))
-		return 1;
-	if (!strncmp(str, "LV", 2))
-		return 1;
-	if (!strncmp(str, "PV", 2))
-		return 1;
-	if (!strncmp(str, "Tag", 3))
-		return 1;
-	if (!strncmp(str, "String", 6))
-		return 1;
-	if (!strncmp(str, "Select", 6))
-		return 1;
+	switch (str[0]) {
+	case 'V': return (str[1] == 'G'); /* VG */
+	case 'L': return (str[1] == 'V'); /* LV */
+	case 'P': return (str[1] == 'V'); /* PV */
+	case 'T': return (strncmp(str, "Tag", 3) == 0);
+	case 'S': return ((strncmp(str, "String", 6) == 0) ||
+			  (strncmp(str, "Select", 6) == 0));
+	}
+
 	return 0;
 }
 


