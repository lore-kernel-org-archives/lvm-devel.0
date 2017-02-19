From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:47:06 +0000 (UTC)
Subject: master - cleanup: same sign for compare
Message-ID: <20170219234706.BB0B660563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2260c6d1e6c9b6332bf24e4237258e92543ce37f
Commit:        2260c6d1e6c9b6332bf24e4237258e92543ce37f
Parent:        d8514b24e115f4c45fb7b6263f553a30e776a3da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 18 19:45:17 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 20 00:43:40 2017 +0100

cleanup: same sign for compare

---
 tools/command.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index f46fb3d..f99d025 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -912,8 +912,6 @@ static void update_prev_opt_arg(struct command *cmd, char *str, int required)
 		cmd->optional_opt_args[cmd->oo_count-1].def = def;
 	else if (required < 0)
 		cmd->ignore_opt_args[cmd->io_count-1].def = def;
-	else
-		return;
 }
 
 /*
@@ -1529,7 +1527,7 @@ static void _print_usage_description(struct command *cmd)
 {
 	const char *desc = cmd->desc;
 	char buf[MAX_LINE] = {0};
-	int di = 0;
+	unsigned di = 0;
 	int bi = 0;
 
 	for (di = 0; di < strlen(desc); di++) {


