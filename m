From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 03:09:50 -0400
Subject: [PATCH 3/4] Remove READ_REQUIRE_RESIZEABLE flag from vgsplit.
In-Reply-To: <1247468991-13691-3-git-send-email-dwysocha@redhat.com>
References: <1247468991-13691-1-git-send-email-dwysocha@redhat.com>
	<1247468991-13691-2-git-send-email-dwysocha@redhat.com>
	<1247468991-13691-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1247468991-13691-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove READ_REQUIRE_RESIZEABLE flag from vgsplit similar to the removal from
vgextend.  Move the check inside the functions that actually move pvs from
one vg structure to another.  Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   10 ++++++++++
 tools/vgsplit.c         |    6 ++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 61e1c3b..eb1192d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -70,6 +70,8 @@ static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group
 static vg_t *_vg_make_handle(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     uint32_t failure);
+static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
+				    uint32_t status);
 
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
@@ -287,6 +289,10 @@ int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 		return 0;
 	}
 
+	if (_vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
+	    _vg_bad_status_bits(vg_to, RESIZEABLE_VG))
+		return 0;
+
 	dm_list_move(&vg_to->pvs, &pvl->list);
 
 	vg_from->pv_count--;
@@ -319,6 +325,10 @@ int move_pvs_used_by_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
+	if (_vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
+	    _vg_bad_status_bits(vg_to, RESIZEABLE_VG))
+		return 0;
+
 	dm_list_iterate_items(lvseg, &lvl->lv->segments) {
 		if (lvseg->log_lv)
 			if (!move_pvs_used_by_lv(vg_from, vg_to,
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index f4f9e6f..35c425a 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -248,8 +248,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
-				     READ_REQUIRE_RESIZEABLE);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
 	if (vg_read_error(vg_from)) {
 		vg_release(vg_from);
 		return ECMD_FAILED;
@@ -283,8 +282,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (vg_read_error(vg_to) == FAILED_EXIST) {
 		existing_vg = 1;
 		vg_release(vg_to);
-		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
-					   READ_REQUIRE_RESIZEABLE);
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
 
 		if (vg_read_error(vg_to)) {
 			vg_release(vg_to);
-- 
1.6.0.6


