From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 13 Feb 2015 17:02:47 +0000 (UTC)
Subject: master - toollib: add underscore to static ignore_vg function
Message-ID: <20150213170247.A5C866050D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=737c992431aed05ed21d55e08a801660d0faa4b1
Commit:        737c992431aed05ed21d55e08a801660d0faa4b1
Parent:        d3f3878ffd2b8da9702865dc6d9ead9f11fdbb0e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 13 11:01:55 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 13 11:01:55 2015 -0600

toollib: add underscore to static ignore_vg function

---
 tools/toollib.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b7e4f53..659eab5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -176,8 +176,8 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
  *
  * Case c covers the other errors returned when reading the VG.
  */
-static int ignore_vg(struct volume_group *vg, const char *vg_name,
-		     struct dm_list *arg_vgnames, int allow_inconsistent, int *skip)
+static int _ignore_vg(struct volume_group *vg, const char *vg_name,
+		      struct dm_list *arg_vgnames, int allow_inconsistent, int *skip)
 {
 	uint32_t read_error = vg_read_error(vg);
 	*skip = 0;
@@ -1790,7 +1790,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		skip = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags);
-		if (ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		if (_ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			release_vg(vg);
@@ -2230,7 +2230,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		}
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags);
-		if (ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		if (_ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			release_vg(vg);
@@ -2704,7 +2704,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		skip = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT);
-		if (ignore_vg(vg, vg_name, NULL, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		if (_ignore_vg(vg, vg_name, NULL, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			release_vg(vg);


