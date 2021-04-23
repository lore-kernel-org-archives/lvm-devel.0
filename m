From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:52 +0000 (GMT)
Subject: main - cov: ensure segtype is not null
Message-ID: <20210423210552.CBD15393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04fd55a0c9e721e8d73f067f886736377ba879e3
Commit:        04fd55a0c9e721e8d73f067f886736377ba879e3
Parent:        cdcd8011d05a0cb7c6a07800dae2a0f99da8a5ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 15:11:08 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: ensure segtype is not null

---
 tools/lvconvert.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b50074294..ab6892105 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1373,7 +1373,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 		if (!*lp->type_str) {
 			lp->type_str = SEG_TYPE_NAME_RAID1;
-			lp->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1);
+			if (!(lp->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
+				return_0;
 			type_enforced = 1;
 		}
 	}


