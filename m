From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:33 +0000 (UTC)
Subject: master - thin: deactivate subvolumes
Message-ID: <20121202170233.BABB2A0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ade2f47829f66d061d69844b9911e266751435b7
Commit:        ade2f47829f66d061d69844b9911e266751435b7
Parent:        dde5a6c52b315d7b8e2dd6b91e17eb3955534682
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 2 16:31:27 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:56:44 2012 +0100

thin: deactivate subvolumes

Do not leave active thin data and metadata volumes
if activation of thin pool fails.
---
 tools/lvconvert.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a75a7fc..2ef8d86 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1960,6 +1960,11 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	if (!activate_lv_excl(cmd, pool_lv)) {
 		log_error("Failed to activate pool logical volume %s/%s.",
 			  pool_lv->vg->name, pool_lv->name);
+		/* Deactivate subvolumes */
+		if (!deactivate_lv(cmd, seg_lv(seg, 0)))
+			log_error("Failed to deactivate pool data logical volume.");
+		if (!deactivate_lv(cmd, seg->metadata_lv))
+			log_error("Failed to deactivate pool metadata logical volume.");
 		goto out;
 	}
 


