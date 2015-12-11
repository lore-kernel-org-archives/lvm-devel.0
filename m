From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 11 Dec 2015 21:30:38 +0000 (UTC)
Subject: master - Change messages from verbose to debug
Message-ID: <20151211213038.F325060661@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4aa9e99a1095bcbed503b0adfe20566adf89f3a8
Commit:        4aa9e99a1095bcbed503b0adfe20566adf89f3a8
Parent:        3e48354f2d458e80cab4c096b2869bdc1ad463c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 11 15:28:46 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Dec 11 15:28:46 2015 -0600

Change messages from verbose to debug

These messages about outdated PVs should not
be verbose because they always appear, even
when there are no outdated PVs.
---
 lib/metadata/metadata.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ec645ae..52647c3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3478,7 +3478,7 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 	 * the VG while it's only partially written out.
 	 */
 	if (cmd->system_id && strcmp(vg->system_id, cmd->system_id)) {
-		log_verbose("Skip wiping outdated PVs for foreign VG.");
+		log_debug_metadata("Skip wiping outdated PVs for foreign VG.");
 		return 0;
 	}
 
@@ -3489,7 +3489,7 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 	 * host, same as the foreign VG case.
 	 */
 	if (is_lockd_type(vg->lock_type)) {
-		log_verbose("Skip wiping outdated PVs for shared VG.");
+		log_debug_metadata("Skip wiping outdated PVs for shared VG.");
 		return 0;
 	}
 


