From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  1 Jun 2010 14:07:56 -0400
Subject: [PATCH 1/2] Do not fail lvm_init() if init_logging() generates an errno.
Message-ID: <1275415677-22814-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Revert to original behavior of lvm commands if init_logging() generated an
errno.  Fixes rhbz 592967.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/commands/toolcontext.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 890da3e..33e682b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -195,6 +195,7 @@ static void _init_logging(struct cmd_context *cmd)
 	dm_log_with_errno_init(print_log);
 #endif
 	reset_log_duplicated();
+	reset_lvm_errno(1);
 }
 
 static int _process_config(struct cmd_context *cmd)
-- 
1.6.0.6


