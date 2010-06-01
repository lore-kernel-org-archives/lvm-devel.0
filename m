From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  1 Jun 2010 14:07:57 -0400
Subject: [PATCH 2/2] Revert _init_rand() to reset errno - restores original init behavior.
In-Reply-To: <1275415677-22814-1-git-send-email-dwysocha@redhat.com>
References: <1275415677-22814-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1275415677-22814-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/commands/toolcontext.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 33e682b..7c5e379 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1084,10 +1084,13 @@ static int _init_backup(struct cmd_context *cmd)
 
 static void _init_rand(struct cmd_context *cmd)
 {
-	if (read_urandom(&cmd->rand_seed, sizeof(cmd->rand_seed)))
+	if (read_urandom(&cmd->rand_seed, sizeof(cmd->rand_seed))) {
+		reset_lvm_errno(1);
 		return;
+	}
 
 	cmd->rand_seed = (unsigned) time(NULL) + (unsigned) getpid();
+	reset_lvm_errno(1);
 }
 
 static void _init_globals(struct cmd_context *cmd)
-- 
1.6.0.6


