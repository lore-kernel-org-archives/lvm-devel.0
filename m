From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:58 +0000 (UTC)
Subject: master - vgchange: use NULL 'feature' of lv_info call
Message-ID: <20140924085658.55FBB6109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93fbef1a45948c1f97fe484b4dd65179afa5051d
Commit:        93fbef1a45948c1f97fe484b4dd65179afa5051d
Parent:        5b70bdc104991056a9e1c3f97c07b6f0ba3ae998
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 24 10:01:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

vgchange: use NULL 'feature' of lv_info call

When NULL is passed for info the call itself
already does the same evaluation.
---
 tools/vgchange.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index e817910..350d8a3 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -23,15 +23,13 @@ static int _monitor_lvs_in_vg(struct cmd_context *cmd,
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
-	struct lvinfo info;
 	int r = 1;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
 		if (!lv_info(cmd, lv, lv_is_thin_pool(lv) ? 1 : 0,
-			     &info, 0, 0) ||
-		    !info.exists)
+			     NULL, 0, 0))
 			continue;
 		/*
 		 * FIXME: Need to consider all cases... PVMOVE, etc


