From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 19:44:06 -0500
Subject: [PATCH] Move locking_type reading inside init_locking().
In-Reply-To: <87pri077c5.fsf@eriador.mornfall.net>
References: <87pri077c5.fsf@eriador.mornfall.net>
Message-ID: <1233621846-8740-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/locking/locking.c |    5 +++++
 tools/lvmcmdline.c    |    3 +--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index b5871ae..bf28d9a 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -208,11 +208,16 @@ static void _update_vg_lock_count(uint32_t flags)
 
 /*
  * Select a locking type
+ * type: locking type; if < 0, then read config tree value
  */
 int init_locking(int type, struct cmd_context *cmd)
 {
 	init_lockingfailed(0);
 
+	if (type < 0)
+		type = find_config_tree_int(cmd, "global/locking_type", 1);
+		
+	
 	switch (type) {
 	case 0:
 		init_no_locking(&_locking, cmd);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 2dabe64..bafc6a5 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -995,8 +995,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, nolocking_ARG))
 		locking_type = 0;
 	else
-		locking_type = find_config_tree_int(cmd,
-					       "global/locking_type", 1);
+		locking_type = -1;
 
 	if (!init_locking(locking_type, cmd)) {
 		log_error("Locking type %d initialisation failed.",
-- 
1.6.0.5


