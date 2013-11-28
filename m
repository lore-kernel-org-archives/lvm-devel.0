From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:57 +0000 (UTC)
Subject: master - cleanup: drop extra dm_list_empty
Message-ID: <20131128114857.5496260F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6cfd7b2b93645a96db74f90d57bc5031704c298
Commit:        c6cfd7b2b93645a96db74f90d57bc5031704c298
Parent:        bfcf3edcc69243cfcef6e73e8bbcba0e60366802
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 24 19:03:29 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:45:52 2013 +0100

cleanup: drop extra dm_list_empty

Since dm_list_first has this check already include,
skip extra call in while().
Moreover analyzers are then sure pvl is not NULL.
---
 lib/metadata/metadata.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 60be61e..d55dba1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2798,8 +2798,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	baton.warnings = warnings;
 	baton.vg = vg;
 
-	while (!dm_list_empty(&head.list)) {
-		pvl = (struct pv_list *) dm_list_first(&head.list);
+	while ((pvl = (struct pv_list *) dm_list_first(&head.list))) {
 		dm_list_del(&pvl->list);
 		add_pvl_to_vgs(vg, pvl);
 		vg->extent_count += pvl->pv->pe_count;


