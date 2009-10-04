From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:45 -0400
Subject: [PATCH 08/10] Add implicit pvcreate support to vgcreate and vgextend.
In-Reply-To: <1254697907-16448-8-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-3-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-4-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-5-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-6-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-7-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adds implicit pvcreate support when calling vgcreate or vgextend with
device paths that are not yet PVs.  This changes the behavior of vgcreate
and vgextend from failing with an error message to implicitly pvcreating.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/commands.h |    9 +++++++--
 tools/vgcreate.c |    7 ++++---
 tools/vgextend.c |    7 ++++---
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 73ebd0b..fa27e31 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -757,7 +757,9 @@ xx(vgcreate,
    "\tVolumeGroupName PhysicalVolume [PhysicalVolume...]\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
-   maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG)
+   maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
+   force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
+   metadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
@@ -820,7 +822,10 @@ xx(vgextend,
    "\t[--version]" "\n"
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
-   autobackup_ARG, test_ARG)
+   autobackup_ARG, test_ARG,
+   force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
+   metadatasize_ARG, metadatacopies_ARG, dataalignment_ARG,
+   dataalignmentoffset_ARG)
 
 xx(vgimport,
    "Register exported volume group with system",
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 3d4b1b7..ff5f5ae 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -23,6 +23,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	const char *tag;
 	const char *clustered_message = "";
 	char *vg_name;
+	struct pvcreate_params pp;
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -34,8 +35,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
-	if (argc == 0) {
-		log_error("Please enter physical volume name(s)");
+	fill_default_pvcreate_params(&pp);
+	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
@@ -68,7 +69,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc, argv, NULL))
+	if (!vg_extend(vg, argc, argv, &pp))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
diff --git a/tools/vgextend.c b/tools/vgextend.c
index c97b3bb..76554e7 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -20,6 +20,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	char *vg_name;
 	struct volume_group *vg = NULL;
 	int r = ECMD_FAILED;
+	struct pvcreate_params pp;
 
 	if (!argc) {
 		log_error("Please enter volume group name and "
@@ -31,8 +32,8 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
-	if (argc == 0) {
-		log_error("Please enter physical volume(s)");
+	fill_default_pvcreate_params(&pp);
+	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
@@ -54,7 +55,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		goto_bad;
 
 	/* extend vg */
-	if (!vg_extend(vg, argc, argv, NULL))
+	if (!vg_extend(vg, argc, argv, &pp))
 		goto_bad;
 
 	/* ret > 0 */
-- 
1.6.0.6


