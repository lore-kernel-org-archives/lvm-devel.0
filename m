From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Feb 2017 18:28:16 +0000 (UTC)
Subject: master - man: teaking output format
Message-ID: <20170221182816.AF0476103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7ae57c6a6fd69d23cc8c180920ddca372914419
Commit:        b7ae57c6a6fd69d23cc8c180920ddca372914419
Parent:        21fc35dd1bcd068ad4453e5c18b2d754bdcb12b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 21 12:05:36 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 21 12:27:51 2017 -0600

man: teaking output format

---
 tools/command.c |   34 +++++++++++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index c425fd1..e7596df 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1798,6 +1798,38 @@ static void print_val_man(const char *str)
 		return;
 	}
 
+	/*
+	 * The suffix [k|unit] is just printed in plain text.
+	 * Doing bold k and underlined unit creates a lot of
+	 * visual "noise" that is choppy and hard to read.
+	 * The extra markup in this case doesn't add anything
+	 * that isn't already obvious.
+	 */
+
+	if (!strcmp(str, "Number[k|unit]")) {
+		printf("\\fINumber\\fP[k|unit]");
+		return;
+	}
+
+	if (!strcmp(str, "Number[m|unit]")) {
+		printf("\\fINumber\\fP[m|unit]");
+		return;
+	}
+
+	if (!strcmp(str, "[+|-]Number")) {
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP");
+		return;
+	}
+
+	if (!strcmp(str, "[+|-]Number[%VG|%PVS|%FREE]")) {
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP[\\fB%%VG\\fP|\\fB%%PVS\\fP|\\fB%%FREE\\fP]");
+		return;
+	}
+
+	/*
+	 * I think this bit is almost unnecessary with the specific
+	 * ones checked above.
+	 */
 	if (strstr(str, "Number[") || strstr(str, "]Number")) {
 		for (i = 0; i < strlen(str); i++) {
 			if (str[i] == 'N')
@@ -2666,7 +2698,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	/* Nearly every command uses a number arg somewhere. */
 
 	printf("\n.HP\n");
-	printf("\\fINumber\\fP, \\fISize\\fP");
+	printf("\\fINumber\\fP");
 	printf("\n");
 	printf(".br\n");
 	printf("Input units are always treated as base two values, regardless of unit\n"


