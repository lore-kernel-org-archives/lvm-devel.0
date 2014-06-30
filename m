From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 30 Jun 2014 10:25:17 +0000 (UTC)
Subject: master - thin: do not create reserved LVs
Message-ID: <20140630102517.84012611C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6da14a82c665dd8be0039548a54a87f182508cd9
Commit:        6da14a82c665dd8be0039548a54a87f182508cd9
Parent:        eadcea2dae8c56e96b694cb388999865d2678e22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 30 11:33:23 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 30 12:16:05 2014 +0200

thin: do not create reserved LVs

When creating pool's metadata - create initial LV for clearing with some
generic name and after the volume is create & cleared - rename it to
reserved name '_tmeta/_cmeta'.

We should not expose  'reserved' names for public LVs.
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b8b2951..838eb41 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Do not use reserved _[tc]meta volumes for temporary LVs.
   Leave backup pool metadata with _meta%d suffix instead of reserved _tmeta%d.
   Allow RAID repair to reuse PVs from same image that suffered a failure.
   New RAID images now avoid allocation on any PVs in the same parent RAID LV.
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 8520440..1000680 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -552,7 +552,6 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 	struct lvcreate_params lvc = {
 		.activate = CHANGE_ALY,
 		.alloc = alloc,
-		.lv_name = name,
 		.major = -1,
 		.minor = -1,
 		.permission = LVM_READ | LVM_WRITE,
@@ -578,6 +577,9 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 	if (!(metadata_lv = lv_create_single(pool_lv->vg, &lvc)))
 		return_0;
 
+	if (!lv_rename_update(pool_lv->vg->cmd, metadata_lv, name, 0))
+		return_0;
+
 	return metadata_lv;
 }
 


