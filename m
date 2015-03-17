From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 17 Mar 2015 17:49:33 +0000 (UTC)
Subject: master - metadata: Fix recent vg_validate message text.
Message-ID: <20150317174933.36E8C61089@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95fbbf4f40e8d0e9d9565f5a25f66a8127986822
Commit:        95fbbf4f40e8d0e9d9565f5a25f66a8127986822
Parent:        038013cf42710da3e815713c7e7482fca00e110b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 17 17:48:56 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 17 17:48:56 2015 +0000

metadata: Fix recent vg_validate message text.

---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 21066fb..ed91948 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2576,7 +2576,7 @@ int vg_validate(struct volume_group *vg)
 
 		if (lvl->lv->status & LVM_WRITE_LOCKED) {
 			log_error(INTERNAL_ERROR "LV %s has external flag LVM_WRITE_LOCKED set internally.",
-				  vg->name);
+				  lvl->lv->name);
 			r = 0;
 		}
 


