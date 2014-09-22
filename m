From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:44 +0000 (UTC)
Subject: dev-dct-process-latest - raid: add missing vg_revert
Message-ID: <20140922153744.DA16E60D7D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=569184a3bb124f94bc79c1a1d042f686270e7864
Commit:        569184a3bb124f94bc79c1a1d042f686270e7864
Parent:        dd1fa0e808918b51a690e26de8a8cfff6c307854
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 11 19:58:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:45:14 2014 +0200

raid: add missing vg_revert

After failing vg_write() and suspend_lv() there was missing vg_revert() call.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index be549b8..f65d7fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Add missing vg_revert in suspend_lv() error path in raid target.
   Add missing backup of lvm2 metadata after some raid modifications.
   Use vg memory pool for extent allocation.
   Add allocation/physical_extent_size config option for default PE size of VGs.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 91cc0dd..989244c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -938,6 +938,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 	if (!suspend_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to suspend %s/%s before committing changes",
 			  lv->vg->name, lv->name);
+		vg_revert(lv->vg);
 		return 0;
 	}
 
@@ -1113,6 +1114,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to suspend %s/%s before committing changes",
 			  lv->vg->name, lv->name);
+		vg_revert(lv->vg);
 		return 0;
 	}
 


