From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Jun 2014 10:04:21 +0000 (UTC)
Subject: master - cleanup: more readable
Message-ID: <20140619100421.30714606D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00af0d13c91d24952ec0542b5fe8323835d59051
Commit:        00af0d13c91d24952ec0542b5fe8323835d59051
Parent:        aa3e41309368c1504943b8a116f5a3646777e2a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 19 11:30:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 19 12:02:48 2014 +0200

cleanup: more readable

Older gcc complained a bit about uninitialized vars
so reorder code for better readability.
---
 lib/commands/toolcontext.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index cc08747..326bfe0 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -629,26 +629,21 @@ static int _init_tag_configs(struct cmd_context *cmd)
 static int _init_profiles(struct cmd_context *cmd)
 {
 	const char *dir;
-	struct profile_params *pp;
-	int initialized = cmd->profile_params != NULL;
-
-	if (!initialized && !(pp = dm_pool_zalloc(cmd->libmem, sizeof(*pp)))) {
-		log_error("profile_params alloc failed");
-		return 0;
-	}
 
 	if (!(dir = find_config_tree_str(cmd, config_profile_dir_CFG, NULL)))
 		return_0;
 
-	if (initialized) {
-		dm_strncpy(cmd->profile_params->dir, dir, sizeof(pp->dir));
-	} else {
-		dm_strncpy(pp->dir, dir, sizeof(pp->dir));
-		dm_list_init(&pp->profiles_to_load);
-		dm_list_init(&pp->profiles);
-		cmd->profile_params = pp;
+	if (!cmd->profile_params) {
+		if (!(cmd->profile_params = dm_pool_zalloc(cmd->libmem, sizeof(*cmd->profile_params)))) {
+			log_error("profile_params alloc failed");
+			return 0;
+		}
+		dm_list_init(&cmd->profile_params->profiles_to_load);
+		dm_list_init(&cmd->profile_params->profiles);
 	}
 
+	dm_strncpy(cmd->profile_params->dir, dir, sizeof(cmd->profile_params->dir));
+
 	return 1;
 }
 


