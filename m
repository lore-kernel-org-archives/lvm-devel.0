From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:35 +0000 (GMT)
Subject: main - cov: initialize value
Message-ID: <20210310231935.1CF123857C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7bb23dd156cd059500e32a4f3966d3d1be52225
Commit:        d7bb23dd156cd059500e32a4f3966d3d1be52225
Parent:        23afad824715f941ebeccc2c12aec75fc241b984
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 15:53:58 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

cov: initialize value

Coverity can't understand conditions together, so just keep it quiet.
---
 lib/mm/memlock.c | 2 +-
 tools/command.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 0c05038fe..1e6cedc5f 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -551,7 +551,7 @@ static void _lock_mem(struct cmd_context *cmd)
 
 static void _unlock_mem(struct cmd_context *cmd)
 {
-	size_t unlock_mstats;
+	size_t unlock_mstats = 0;
 
 	log_very_verbose("Unlocking memory");
 
diff --git a/tools/command.c b/tools/command.c
index 81720acf1..bb707d66f 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3595,7 +3595,7 @@ static void _print_man_secondary(char *name)
 
 int main(int argc, char *argv[])
 {
-	struct cmd_context cmdtool;
+	struct cmd_context cmdtool = { 0 };
 	char *cmdname = NULL;
 	char *desfile = NULL;
 	char *stdout_buf;


