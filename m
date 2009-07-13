From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 03:09:48 -0400
Subject: [PATCH 1/4] Remove READ_REQUIRE_RESIZEABLE from vgextend by moving check inside vg_extend.
In-Reply-To: <1247468991-13691-1-git-send-email-dwysocha@redhat.com>
References: <1247468991-13691-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1247468991-13691-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the check for the RESIZEABLE flag inside the vg_extend function.
When we consolidated the vg locking, reading, and status flag checking,
we tied the check for the RESIZEABLE flag to the vg_read() call.  The problem
with this is you cannot know what other APIs the application my or may not
call after a vg_read() call.  Thus the READ_REQUIRE_RESIZEABLE flag is not
really ideal - ideally we should be checking for this flag on a specific
operation, not inside the vg_read() call.  This patch moves one check inside
the library.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    3 +++
 tools/vgextend.c        |    3 +--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2d6cb14..5206258 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -439,6 +439,9 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 	struct physical_volume *pv;
 	struct cmd_context *cmd = vg->cmd;
 
+	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
+		return 0;
+
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return 0;
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 728d9f4..1dfbc11 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -37,8 +37,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	argv++;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	vg = vg_read_for_update(cmd, vg_name, NULL,
-				READ_REQUIRE_RESIZEABLE);
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
 		return ECMD_FAILED;
-- 
1.6.0.6


