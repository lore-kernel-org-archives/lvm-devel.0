From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:09:56 +0000 (UTC)
Subject: master - cleanup: remove wrapping function
Message-ID: <20161213210956.3E7BB607A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fce7449d7311b49839f339b714c48e953e9a837a
Commit:        fce7449d7311b49839f339b714c48e953e9a837a
Parent:        c7da16e5f162193db16f2a1845200fc99ed6ebc3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 13 12:28:12 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 13 22:07:52 2016 +0100

cleanup: remove wrapping function

backup is not 'tested' for success and also it should
actually happen just when command is finished.
We do not target to make backups with each inter-step
metadata change.
---
 lib/metadata/raid_manip.c |   23 ++++++-----------------
 1 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 56fe6a7..049102a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -226,21 +226,6 @@ static void _clear_allocation_prohibited(struct dm_list *pvs)
 			pvl->pv->status &= ~PV_ALLOCATION_PROHIBITED;
 }
 
-/* FIXME Move this out */
-/* Write, commit and optionally backup metadata of vg */
-static int _vg_write_commit_backup(struct volume_group *vg)
-{
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		log_error("Failed to commit VG %s metadata.", vg->name);
-		return 0;
-	}
-
-	if (!backup(vg))
-		log_warn("WARNING: Backup of VG %s metadata failed. Continuing.", vg->name);
-
-	return 1;
-}
-
 /*
  * Deactivate and remove the LVs on removal_lvs list from vg.
  */
@@ -1898,8 +1883,12 @@ static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
 
 	dm_list_init(removal_lvs);
 
-	if (vg_write_requested && !_vg_write_commit_backup(vg))
-		return_0;
+	if (vg_write_requested) {
+		if (!vg_write(vg) || !vg_commit(vg))
+			return_0;
+
+		backup(vg);
+	}
 
 	return 1;
 }


