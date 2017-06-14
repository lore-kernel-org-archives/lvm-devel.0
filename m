From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 14 Jun 2017 16:22:47 -0400
Subject: master - clean-up: Very picky update to comment - hopefully making it clearer
Message-ID: <201706142022.v5EKMlf4001403@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c4b2a6aa16cdb4aff2bd80909dcf43032348a3a
Commit:        6c4b2a6aa16cdb4aff2bd80909dcf43032348a3a
Parent:        1f57a5263e3ef2dd95e91ea39a40e45993d31028
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 14 15:22:04 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 14 15:22:04 2017 -0500

clean-up:  Very picky update to comment - hopefully making it clearer

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index dca5ba3..ade27e6 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -309,7 +309,7 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
 				  "LVs must be set visible before removing.");
 			return 0;
 		}
-		/* Got to get any cluster lock an SubLVs to be removed. */
+		/* Must get a cluster lock on SubLVs that will be removed. */
 		if (!activate_lv_excl_local(vg->cmd, lvl->lv))
 			return_0;
 	}


