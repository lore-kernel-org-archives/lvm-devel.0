From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 13 Feb 2015 17:38:02 +0000 (UTC)
Subject: master - system_id: warn if the system_id_file cannot be opened
Message-ID: <20150213173802.3415760221@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d726246f78ed7b8b957d45abe9084fb0b47c7240
Commit:        d726246f78ed7b8b957d45abe9084fb0b47c7240
Parent:        def0866ded7c11b1a93fa7bd093e2433d90f09d3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 13 11:37:11 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 13 11:37:11 2015 -0600

system_id: warn if the system_id_file cannot be opened

---
 lib/commands/toolcontext.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8cbe88f..f984f70 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -81,9 +81,10 @@ static char *_read_system_id_from_file(struct cmd_context *cmd, const char *file
 	if (!file || !strlen(file) || !file[0])
 		return NULL;
 
-	fp = fopen(file, "r");
-	if (!fp)
+	if (!(fp = fopen(file, "r"))) {
+		log_warn("WARNING: Error %d opening system_id_file %s", errno, file);
 		return NULL;
+	}
 
 	memset(line, 0, sizeof(line));
 
@@ -91,11 +92,13 @@ static char *_read_system_id_from_file(struct cmd_context *cmd, const char *file
 		if (line[0] == '#' || line[0] == '\n')
 			continue;
 
-		fclose(fp);
+		if (fclose(fp))
+			stack;
 		return system_id_from_string(cmd, line);
 	}
 
-	fclose(fp);
+	if (fclose(fp))
+		stack;
 	return NULL;
 }
 


