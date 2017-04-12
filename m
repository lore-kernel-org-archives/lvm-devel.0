From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 15:38:53 -0400
Subject: master - cmdline: ensure command struct is defined
Message-ID: <201704121938.v3CJcrDv012255@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3503ef23e30da87f16b881248be92842a774d7d9
Commit:        3503ef23e30da87f16b881248be92842a774d7d9
Parent:        635e7e0c928aba62f7d6ddf892978ece6217b905
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 1 12:17:16 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 21:33:47 2017 +0200

cmdline: ensure command struct is defined

Make it clear to Coverity cmd will be defined.
---
 tools/lvmcmdline.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4d20d08..4f66f7e 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1832,7 +1832,7 @@ static void _short_usage(const char *name)
 static int _usage(const char *name, int longhelp, int skip_notes)
 {
 	struct command_name *cname = find_command_name(name);
-	struct command *cmd;
+	struct command *cmd = NULL;
 	int show_full = longhelp;
 	int i;
 
@@ -1876,6 +1876,11 @@ static int _usage(const char *name, int longhelp, int skip_notes)
 	}
 
 	/* Common options are printed once for all variants of a command name. */
+	if (!cmd) {
+		log_error(INTERNAL_ERROR "Command %s not found.", name);
+		return 0;
+	}
+
 	print_usage_common_cmd(cname, cmd);
 	print_usage_common_lvm(cname, cmd);
 


