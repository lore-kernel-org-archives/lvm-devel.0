From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:49 -0400
Subject: master - lvmlockd: fix vgimportclone of a shared VG
Message-ID: <201805311414.w4VEEnvF031232@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c5e449dc5f955481f9409ff0e7ed39cf7b2e87d
Commit:        5c5e449dc5f955481f9409ff0e7ed39cf7b2e87d
Parent:        a40d447a02521820c23422fdd43f795c32d402a7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 15:26:30 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

lvmlockd: fix vgimportclone of a shared VG

The new VG from the duplicate PV is imported
as a local VG.
---
 test/shell/vgimportclone.sh |    5 ++---
 tools/vgimportclone.c       |   15 ++++++++++++++-
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index f97c6df..48a666e 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -10,14 +10,13 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
 aux prepare_devs 2
 
-vgcreate --metadatasize 128k $vg1 "$dev1"
+vgcreate $SHARED --metadatasize 128k $vg1 "$dev1"
 lvcreate -l100%FREE -n $lv1 $vg1
 
 # Test plain vgexport vgimport tools
@@ -76,7 +75,7 @@ vgremove -ff $vg1 $vg2
 
 # Verify that if we provide the -n|--basevgname,
 # the number suffix is not added unnecessarily.
-vgcreate --metadatasize 128k A${vg1}B "$dev1"
+vgcreate $SHARED --metadatasize 128k A${vg1}B "$dev1"
 
 # vg1B is not the same as Avg1B - we don't need number suffix
 dd if="$dev1" of="$dev2" bs=256K count=1
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 224d0b5..c4c5d4c 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -153,6 +153,11 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 	if (!(vg->name = dm_pool_strdup(vg->vgmem, vp->new_vgname)))
 		goto_bad;
 
+	/* A duplicate of a shared VG is imported as a new local VG. */
+	vg->lock_type = NULL;
+	vg->lock_args = NULL;
+	vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl))))
 			goto_bad;
@@ -174,8 +179,10 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 		dm_list_add(&vg->pv_write_list, &new_pvl->list);
 	}
 
-	dm_list_iterate_items(lvl, &vg->lvs)
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		memcpy(&lvl->lv->lvid, &vg->id, sizeof(vg->id));
+		lvl->lv->lock_args = NULL;
+	}
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		goto_bad;
@@ -343,6 +350,12 @@ retry_name:
 		goto out;
 	}
 
+	/*
+	 * Trying to lock the duplicated VG would conflict with the original,
+	 * and it's not needed because the new VG will be imported as a local VG.
+	 */
+	cmd->lockd_vg_disable = 1;
+
 	ret = process_each_vg(cmd, 0, NULL, vp.old_vgname, NULL, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, 0, handle, _vgimportclone_vg_single);
 
 	unlock_vg(cmd, NULL, vp.new_vgname);


