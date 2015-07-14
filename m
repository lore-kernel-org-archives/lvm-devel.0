From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Jul 2015 19:43:51 +0000 (UTC)
Subject: master - metadata: change function name to _allow_extra_system_id
Message-ID: <20150714194352.0081F60ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96a883a4541211fc3af09f682854ed88e200c036
Commit:        96a883a4541211fc3af09f682854ed88e200c036
Parent:        9ab6bdce01d7780a9c8f7194bc488032dbf3348f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 14 14:42:18 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 14 14:43:16 2015 -0500

metadata: change function name to _allow_extra_system_id

The previous name was misleading since this is not the
primary system_id check, only the "extra" check.
---
 lib/metadata/metadata.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3ebcc2d..56ed3fb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4707,7 +4707,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 	return (struct volume_group *)vg;
 }
 
-static int _allow_system_id(struct cmd_context *cmd, const char *system_id)
+static int _allow_extra_system_id(struct cmd_context *cmd, const char *system_id)
 {
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
@@ -4848,7 +4848,7 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	/*
 	 * A host can access a VG if the VG's system_id is in extra_system_ids list.
 	 */
-	if (cmd->system_id && _allow_system_id(cmd, vg->system_id))
+	if (cmd->system_id && _allow_extra_system_id(cmd, vg->system_id))
 		return 1;
 
 	/*


