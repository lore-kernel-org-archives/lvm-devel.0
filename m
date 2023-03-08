From: David Teigland <teigland@sourceware.org>
Date: Wed,  8 Mar 2023 17:13:10 +0000 (GMT)
Subject: main - lvmlockd: clean up get_local_nodeid
Message-ID: <20230308171310.800143858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da44f2b6fe1e0edbd3ee875c831f3e467f242bc0
Commit:        da44f2b6fe1e0edbd3ee875c831f3e467f242bc0
Parent:        cd14d3fcc0e03136d0cea1ab1a9edff3b8b9dbeb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 8 11:11:32 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 11:11:32 2023 -0600

lvmlockd: clean up get_local_nodeid

Hard to see if fclose calls were correct, and coverity couldn't figure
it out either, so make it clear.
---
 daemons/lvmlockd/lvmlockd-dlm.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 248081d0e..ce9d9acf2 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -227,8 +227,9 @@ static int get_local_nodeid(void)
 	struct dirent *de;
 	DIR *ls_dir;
 	char ls_comms_path[PATH_MAX];
-	FILE *file = NULL;
+	FILE *file;
 	char line[LOCK_LINE_MAX];
+	char *str1, *str2;
 	int rv = -1, val;
 
 	memset(ls_comms_path, 0, sizeof(ls_comms_path));
@@ -243,30 +244,33 @@ static int get_local_nodeid(void)
 		memset(ls_comms_path, 0, sizeof(ls_comms_path));
 		snprintf(ls_comms_path, PATH_MAX, "%s/%s/local",
 		     DLM_COMMS_PATH, de->d_name);
-		file = fopen(ls_comms_path, "r");
-		if (!file)
+
+		if (!(file = fopen(ls_comms_path, "r")))
 			continue;
-		if (fgets(line, LOCK_LINE_MAX, file)) {
-			fclose(file);
+		str1 = fgets(line, LOCK_LINE_MAX, file);
+		fclose(file);
+
+		if (str1) {
 			rv = sscanf(line, "%d", &val);
 			if ((rv == 1) && (val == 1 )) {
 				memset(ls_comms_path, 0, sizeof(ls_comms_path));
 				snprintf(ls_comms_path, PATH_MAX, "%s/%s/nodeid",
 				    DLM_COMMS_PATH, de->d_name);
-				file = fopen(ls_comms_path, "r");
-				if (!file)
+
+				if (!(file = fopen(ls_comms_path, "r")))
 					continue;
-				if (fgets(line, LOCK_LINE_MAX, file)) {
+				str2 = fgets(line, LOCK_LINE_MAX, file);
+				fclose(file);
+
+				if (str2) {
 					rv = sscanf(line, "%d", &val);
 					if (rv == 1) {
-						fclose(file);
 						closedir(ls_dir);
 						return val;
 					}
 				}
 			}
 		}
-		fclose(file);
 	}
 
 	if (closedir(ls_dir))

