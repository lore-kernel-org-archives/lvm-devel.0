From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:06 +0100
Subject: [PATCH 02/29] Fix check for empty system_dir
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <ced2653c100dd20c1ed531b6ce59ae14a7396b13.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fixing most probably a typo - I assume original intention has been
to check for zero length string.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f714cdf..b8da161 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1036,7 +1036,7 @@ static int _init_backup(struct cmd_context *cmd)
 	char default_dir[PATH_MAX];
 	const char *dir;
 
-	if (!cmd->system_dir) {
+	if (!*cmd->system_dir) {
 		log_warn("WARNING: Metadata changes will NOT be backed up");
 		backup_init(cmd, "", 0);
 		archive_init(cmd, "", 0, 0, 0);
-- 
1.7.3.2


