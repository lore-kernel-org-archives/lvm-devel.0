From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:41 +0000 (UTC)
Subject: master - lv_ondisk: option search for lv without vg_ondisk
Message-ID: <20140924085641.80EB76109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9776979b02ddd6405e13208a74fedfee0e1cfec3
Commit:        9776979b02ddd6405e13208a74fedfee0e1cfec3
Parent:        0f2adcc9efc8621fa5cf3a1871f2294fa7da7f1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 23:10:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:48:01 2014 +0200

lv_ondisk: option search for lv without vg_ondisk

When vg_ondisk is NULL we do not need to search
through the whole VG to find out the same LV.

NOTE: as of now - VG locking is not enabled as some code parts
are breaking memory locking rules (lvm2app).

Once we enforce VG locking for read-only commands the effect
will be much better for larger VGs.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b4ee934..9869130 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Improve search of LV in lv_ondisk().
   Do not scan sysfs in lv_check_not_in_use() when device is closed.
   Backup final metadata after resync of mirror/raid.
   Unify handling of --persistent option for lvcreate and lvchange.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0842563..464b8bc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4813,10 +4813,10 @@ struct logical_volume *lv_ondisk(struct logical_volume *lv)
 	if (!lv)
 		return NULL;
 
-	vg = lv->vg;
+	if (!lv->vg->vg_ondisk)
+		return lv;
 
-	if (vg->vg_ondisk)
-		vg = vg->vg_ondisk;
+	vg = lv->vg->vg_ondisk;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!strncmp(lvl->lv->lvid.s, lv->lvid.s, sizeof(lv->lvid)))


