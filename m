From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:30 +0000 (UTC)
Subject: master - fix lvmcmdline warning
Message-ID: <20170213181030.C33C16039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3642deb4f3b7ade1109aeb0ef2cffb38f31ff7c6
Commit:        3642deb4f3b7ade1109aeb0ef2cffb38f31ff7c6
Parent:        4d2c3502e79e34a5cf0fdb65c2a4df23aa1b2ecb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 12 14:36:31 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

fix lvmcmdline warning

declaration of ???usage??? shadows a globa
---
 tools/lvmcmdline.c |   40 ++++++++++++++++++++--------------------
 1 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index afc941b..ddc87f9 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1288,7 +1288,7 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 
 #define HELP_LINE_SIZE 1024
 
-static void _print_usage(const char *usage, int only_required)
+static void _print_usage(const char *usage_str, int only_required)
 {
 	char buf[HELP_LINE_SIZE];
 	int optional_ui = 0;
@@ -1296,7 +1296,7 @@ static void _print_usage(const char *usage, int only_required)
 	int ui;
 	int bi;
 
-	if (!usage || !strlen(usage))
+	if (!usage_str || !strlen(usage_str))
 		return;
 
 	/*
@@ -1313,32 +1313,32 @@ static void _print_usage(const char *usage, int only_required)
 	memset(buf, 0, sizeof(buf));
 	bi = 0;
 
-	for (ui = 0; ui < strlen(usage); ui++) {
-		if (!bi && ((usage[ui] == ' ') || (usage[ui] == '\n')))
+	for (ui = 0; ui < strlen(usage_str); ui++) {
+		if (!bi && ((usage_str[ui] == ' ') || (usage_str[ui] == '\n')))
 			continue;
 
 		/* The first "[ " indicates the start of the optional opt_args. */
-		if ((usage[ui] == '[') && (usage[ui+1] == ' ')) {
+		if ((usage_str[ui] == '[') && (usage_str[ui+1] == ' ')) {
 			optional_ui = ui;
 			break;
 		}
 
-		if (usage[ui] == '\0')
+		if (usage_str[ui] == '\0')
 			break;
 
-		if (usage[ui] == '(') {
+		if (usage_str[ui] == '(') {
 			buf[bi++] = '\n';
 			buf[bi++] = '\t';
 		}
 
-		buf[bi++] = usage[ui];
+		buf[bi++] = usage_str[ui];
 
-		if (usage[ui] == ')') {
+		if (usage_str[ui] == ')') {
 			buf[bi++] = '\n';
 			buf[bi++] = '\t';
 		}
 
-		if (usage[ui] == ',') {
+		if (usage_str[ui] == ',') {
 			buf[bi++] = '\n';
 			buf[bi++] = '\t';
 			buf[bi++] = ' ';
@@ -1368,25 +1368,25 @@ static void _print_usage(const char *usage, int only_required)
 	memset(buf, 0, sizeof(buf));
 	bi = 0;
 
-	for (ui = optional_ui; ui < strlen(usage); ui++) {
+	for (ui = optional_ui; ui < strlen(usage_str); ui++) {
 
 		/* The second "[ " indicates the start of the optional pos_args. */
-		if ((ui > optional_ui) && (usage[ui] == '[') && (usage[ui+1] == ' ')) {
+		if ((ui > optional_ui) && (usage_str[ui] == '[') && (usage_str[ui+1] == ' ')) {
 			optional_pos_ui = ui;
 			break;
 		}
 
-		if (usage[ui] == '\0')
+		if (usage_str[ui] == '\0')
 			break;
-		if (usage[ui] == '\n')
+		if (usage_str[ui] == '\n')
 			break;
 
 		if (!bi)
 			buf[bi++] = '\t';
 
-		buf[bi++] = usage[ui];
+		buf[bi++] = usage_str[ui];
 
-		if (usage[ui] == ',') {
+		if (usage_str[ui] == ',') {
 			buf[bi++] = '\n';
 			buf[bi++] = '\t';
 			buf[bi++] = ' ';
@@ -1413,16 +1413,16 @@ static void _print_usage(const char *usage, int only_required)
 	memset(buf, 0, sizeof(buf));
 	bi = 0;
 
-	for (ui = optional_pos_ui; ui < strlen(usage); ui++) {
-		if (usage[ui] == '\0')
+	for (ui = optional_pos_ui; ui < strlen(usage_str); ui++) {
+		if (usage_str[ui] == '\0')
 			break;
-		if (usage[ui] == '\n')
+		if (usage_str[ui] == '\n')
 			break;
 
 		if (!bi)
 			buf[bi++] = '\t';
 
-		buf[bi++] = usage[ui];
+		buf[bi++] = usage_str[ui];
 
 		if (bi == (HELP_LINE_SIZE - 1))
 			break;


