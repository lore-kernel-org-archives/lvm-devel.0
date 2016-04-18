From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 10:59:05 +0000 (UTC)
Subject: master - debug: fix error message
Message-ID: <20160418105905.DA82A61B7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5cf6cc9ed756ec1e98d62a31aba803577443ad7
Commit:        f5cf6cc9ed756ec1e98d62a31aba803577443ad7
Parent:        9cccf5245a97a64f900f253fcf948edd5d7ba8c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 17 14:44:13 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 12:32:56 2016 +0200

debug: fix error message

log_error is replaced with warn since the result
of function is not result in command error.
---
 lib/activate/dev_manager.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2b108c9..b155039 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -766,11 +766,11 @@ static const struct dm_info *_cached_dm_info(struct dm_pool *mem,
 		return_NULL;
 
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid)))
-		goto_out;
+		goto out;
 
 	if (!(dinfo = dm_tree_node_get_info(dnode))) {
-		log_error("Failed to get info from tree node for %s.",
-			  display_lvname(lv));
+		log_warn("WARNING: Cannot get info from tree node for %s.",
+			 display_lvname(lv));
 		goto out;
 	}
 


