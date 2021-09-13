From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:10 +0000 (GMT)
Subject: main - cov: do not try to change passed in argv
Message-ID: <20210913103610.5B2953858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7258ae39421f60c41f9ec79242f31b468a7460e
Commit:        a7258ae39421f60c41f9ec79242f31b468a7460e
Parent:        aa522d586227ecafb18d671cab284ae27ca65eed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 10 16:04:43 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: do not try to change passed in argv

It's not a good idea to change passed 'argv[]' and replace it with
pointers to local stack - although in this case we are not using
this argv[] after return from this function.
---
 tools/lvmcmdline.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 27c41412d..1fb593d84 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3586,6 +3586,8 @@ static int _run_script(struct cmd_context *cmd, int argc, char **argv)
 	int ret = ENO_SUCH_CMD;
 	int magic_number = 0;
 	char *script_file = argv[0];
+	int largc;
+	char *largv[MAX_ARGS];
 
 	if ((script = fopen(script_file, "r")) == NULL)
 		return ENO_SUCH_CMD;
@@ -3607,17 +3609,17 @@ static int _run_script(struct cmd_context *cmd, int argc, char **argv)
 			ret = EINVALID_CMD_LINE;
 			break;
 		}
-		if (lvm_split(buffer, &argc, argv, MAX_ARGS) == MAX_ARGS) {
+		if (lvm_split(buffer, &largc, largv, MAX_ARGS) == MAX_ARGS) {
 			buffer[50] = '\0';
 			log_error("Too many arguments: %s", buffer);
 			ret = EINVALID_CMD_LINE;
 			break;
 		}
-		if (!argc)
+		if (!largc)
 			continue;
-		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit"))
+		if (!strcmp(largv[0], "quit") || !strcmp(largv[0], "exit"))
 			break;
-		ret = lvm_run_command(cmd, argc, argv);
+		ret = lvm_run_command(cmd, largc, largv);
 		/*
 		 * FIXME: handling scripts with invalid or failing commands
 		 * could use some cleaning up, e.g. error_message_produced


