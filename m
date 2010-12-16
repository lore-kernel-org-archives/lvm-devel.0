From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:23 +0100
Subject: [PATCH 15/20] Remove dead assignment in _init_logging
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <f4d9c6455540c6e34f4d1c8bdbe22fb802816038.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

old_mask is not used later - so remove it.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c5fc057..9791b45 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -200,7 +200,6 @@ static void _init_logging(struct cmd_context *cmd)
 
 static int _process_config(struct cmd_context *cmd)
 {
-	mode_t old_umask;
 	const char *read_ahead;
 	struct stat st;
 	const struct config_node *cn;
@@ -211,7 +210,7 @@ static int _process_config(struct cmd_context *cmd)
 						      "global/umask",
 						      DEFAULT_UMASK);
 
-	if ((old_umask = umask((mode_t) cmd->default_settings.umask)) !=
+	if (umask((mode_t) cmd->default_settings.umask) !=
 	    (mode_t) cmd->default_settings.umask)
 		log_verbose("Set umask to %04o", cmd->default_settings.umask);
 
-- 
1.7.3.3


