From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:55:42 +0000 (UTC)
Subject: master - cleanup: drop unintend debug error line
Message-ID: <20140711115542.543F960D03@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7913f64a020db49cf2715d64982571d035ced893
Commit:        7913f64a020db49cf2715d64982571d035ced893
Parent:        a62cea3371cfac10f74a135b1969120e10f48f60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 13:54:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:54:54 2014 +0200

cleanup: drop unintend debug error line

---
 tools/lvconvert.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3a5f129..04bb202 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -165,7 +165,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	if ((ptr = strrchr(lp->lv_name_full, '/')))
 		lp->lv_name = ptr + 1;
 	else
-                lp->lv_name = lp->lv_name_full;
+		lp->lv_name = lp->lv_name_full;
 
 	if (!lp->merge_mirror &&
 	    !strstr(lp->lv_name, "_tdata") &&
@@ -173,8 +173,6 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	    !apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
-	log_error("PAR  %d  t:%d  c:%d  m:%s d:%s  l:%s", *pargc, lp->thin,lp->cache,
-		  lp->pool_metadata_lv_name, lp->pool_data_lv_name, lp->lv_name);
 	if (*pargc) {
 		if (lp->snapshot) {
 			log_error("Too many arguments provided for snapshots.");


