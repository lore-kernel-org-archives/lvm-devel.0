From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  8 Jul 2015 15:59:28 +0000 (UTC)
Subject: master - lvmlockctl: fix uninitialized names
Message-ID: <20150708155928.792FD61178@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2566bdfbc3dd1ca7296d8828bb4235c18e06672e
Commit:        2566bdfbc3dd1ca7296d8828bb4235c18e06672e
Parent:        143a9d7ee690c68269572a44f4f1e396916c9b57
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 8 10:57:57 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 8 10:58:56 2015 -0500

lvmlockctl: fix uninitialized names

When formatting and printing info from lvmlockd.
Also fix some new line problems.
---
 daemons/lvmlockd/lvmlockctl.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 33f0a6f..bc5ec78 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -135,7 +135,7 @@ static void format_info_ls_action(char *line)
 
 	find_client_info(client_id, &pid, cl_name);
 
-	printf("OP %s pid %u (%s)", op, pid, cl_name);
+	printf("OP %s pid %u (%s)\n", op, pid, cl_name);
 }
 
 static void format_info_r(char *line, char *r_name_out, char *r_type_out)
@@ -242,13 +242,10 @@ static void format_info_r_action(char *line, char *r_name, char *r_type)
 	}
 }
 
-static void format_info_line(char *line)
+static void format_info_line(char *line, char *r_name, char *r_type)
 {
-	char r_name[MAX_NAME+1];
-	char r_type[MAX_NAME+1];
-
 	if (!strncmp(line, "info=structs ", strlen("info=structs "))) {
-		printf("%s\n", line);
+		printf("%s", line);
 
 	} else if (!strncmp(line, "info=client ", strlen("info=client "))) {
 		save_client_info(line);
@@ -260,8 +257,13 @@ static void format_info_line(char *line)
 		format_info_ls_action(line);
 
 	} else if (!strncmp(line, "info=r ", strlen("info=r "))) {
-		memset(r_name, 0, sizeof(r_name));
-		memset(r_type, 0, sizeof(r_type));
+		/*
+		 * r_name/r_type are reset when a new resource is found.
+		 * They are reused for the lock and action lines that
+		 * follow a resource line.
+		 */
+		memset(r_name, 0, MAX_NAME+1);
+		memset(r_type, 0, MAX_NAME+1);
 		format_info_r(line, r_name, r_type);
 
 	} else if (!strncmp(line, "info=lk ", strlen("info=lk "))) {
@@ -270,7 +272,6 @@ static void format_info_line(char *line)
 
 	} else if (!strncmp(line, "info=r_action ", strlen("info=r_action "))) {
 		/* will use info from previous r */
-		/* FIXME: r_name and r_type uninitialized here??? */
 		format_info_r_action(line, r_name, r_type);
 	} else {
 		printf("UN %s\n", line);
@@ -280,6 +281,8 @@ static void format_info_line(char *line)
 static void format_info(void)
 {
 	char line[MAX_LINE];
+	char r_name[MAX_NAME+1];
+	char r_type[MAX_NAME+1];
 	int i, j;
 
 	j = 0;
@@ -289,7 +292,7 @@ static void format_info(void)
 		line[j++] = dump_buf[i];
 
 		if ((line[j-1] == '\n') || (line[j-1] == '\0')) {
-			format_info_line(line);
+			format_info_line(line, r_name, r_type);
 			j = 0;
 			memset(line, 0, sizeof(line));
 		}


