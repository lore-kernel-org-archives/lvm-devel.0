From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:10 +0000 (UTC)
Subject: master - cleanup: use find_lv_in_vg_by_lvid
Message-ID: <20140924085710.E4C5A60D58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1213401393ac6e6a9a9e168379574469eb715c8
Commit:        a1213401393ac6e6a9a9e168379574469eb715c8
Parent:        a8aee7dba2b76409d1630edc4f76021b50b08792
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 11:46:34 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

cleanup: use find_lv_in_vg_by_lvid

Replace another loop with existion function.

TODO: consider using hash maps for lvname & lvid lookups.
---
 lib/metadata/metadata.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 04d63eb..353db25 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4818,11 +4818,11 @@ const struct logical_volume *lv_ondisk(const struct logical_volume *lv)
 
 	vg = lv->vg->vg_ondisk;
 
-	dm_list_iterate_items(lvl, &vg->lvs)
-		if (!strncmp(lvl->lv->lvid.s, lv->lvid.s, sizeof(lv->lvid)))
-			return lvl->lv;
+	if (!(lvl = find_lv_in_vg_by_lvid(vg, &lv->lvid))) {
+		log_error(INTERNAL_ERROR "LV %s (UUID %s) not found in ondisk metadata.",
+			  display_lvname(lv), lv->lvid.s);
+		return NULL;
+	}
 
-	log_error(INTERNAL_ERROR "LV %s/%s (UUID %s) not found in ondisk metadata.",
-		  lv->vg->name, lv->name, lv->lvid.s);
-	return NULL;
+	return lvl->lv;
 }


