From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:48 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: fix tabs
Message-ID: <20130604192748.6A40B61265@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f9366696c76863662e6cb12de467b5f748c8495
Commit:        6f9366696c76863662e6cb12de467b5f748c8495
Parent:        a766ea16b86501b6241cf7ba96dd0f28e1cf35b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 30 17:56:02 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:56:41 2013 +0200

cleanup: fix tabs

---
 tools/lvcreate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 497c474..3f2f17b 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -310,7 +310,7 @@ static int _update_extents_params(struct volume_group *vg,
 		extents = cow_max_extents(origin, lp->chunk_size);
 
 		if (extents < lp->extents) {
-				log_print_unless_silent("Reducing COW size %s down to maximum usable size %s.",
+			log_print_unless_silent("Reducing COW size %s down to maximum usable size %s.",
 						display_size(vg->cmd, (uint64_t) vg->extent_size * lp->extents),
 						display_size(vg->cmd, (uint64_t) vg->extent_size * extents));
 			lp->extents = extents;


