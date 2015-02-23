From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 20:55:28 +0000 (UTC)
Subject: master - systemid: Define file content more precisely.
Message-ID: <20150223205529.0DCB3606D6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e15b439bf346f8dc618bef9380b12eb595519a2c
Commit:        e15b439bf346f8dc618bef9380b12eb595519a2c
Parent:        c2ed5feee504185faeba8e85c32769b5dba8a3f2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 20:49:15 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 20:49:15 2015 +0000

systemid: Define file content more precisely.

In a file containing a system ID:
  Any whitespace at the start of a line is ignored;
  Blank lines are ignored;
  Any characters after a # are ignored along with the #.
  The system ID is obtained by processing the first line with
non-ignored characters.
  If further lines with non-ignored characters follow, a warning is
issued.
---
 lib/commands/toolcontext.c |   41 +++++++++++++++++++++++++++++++----------
 1 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 164b344..58f3b5e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -84,31 +84,52 @@ char *system_id_from_string(struct cmd_context *cmd, const char *str)
 
 static char *_read_system_id_from_file(struct cmd_context *cmd, const char *file)
 {
-	char line[NAME_LEN + 1];
+	char *line = NULL;
+	size_t line_size;
+	char *start, *end;
+	char *system_id = NULL;
 	FILE *fp;
 
 	if (!file || !strlen(file) || !file[0])
-		return NULL;
+		return_NULL;
 
 	if (!(fp = fopen(file, "r"))) {
-		log_warn("WARNING: Error %d opening system_id_file %s", errno, file);
+		log_warn("WARNING: %s: fopen failed: %s", file, strerror(errno));
 		return NULL;
 	}
 
-	memset(line, 0, sizeof(line));
+	while (getline(&line, &line_size, fp) > 0) {
+		start = line;
+
+		/* Ignore leading whitespace */
+		while (*start && isspace(*start))
+			start++;
 
-	while (fgets(line, NAME_LEN, fp)) {
-		if (line[0] == '#' || line[0] == '\n')
+		/* Ignore rest of line after # */
+		if (!*start || *start == '#')
 			continue;
 
-		if (fclose(fp))
-			stack;
-		return system_id_from_string(cmd, line);
+		if (system_id) {
+			log_warn("WARNING: Ignoring extra line(s) in system ID file %s.", file);
+			break;
+		}
+
+		/* Remove any comments from end of line */
+		for (end = start; *end; start++)
+			if (*end == '#') {
+				*end = '\0';
+				break;
+			}
+
+		system_id = system_id_from_string(cmd, start);
 	}
 
+	free(line);
+
 	if (fclose(fp))
 		stack;
-	return NULL;
+
+	return system_id;
 }
 
 static char *_system_id_from_source(struct cmd_context *cmd, const char *source)


