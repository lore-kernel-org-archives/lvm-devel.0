From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:18:20 +0000 (UTC)
Subject: master - tools: add embeddingareasize arg to pvcreate and vgconvert
Message-ID: <20130226141820.337CEA0C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86f65a3f2bf994a23aed7b29aae9bbab833d485a
Commit:        86f65a3f2bf994a23aed7b29aae9bbab833d485a
Parent:        b778653f03702a967df11d51d842abb9a9b86068
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 15 11:14:26 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 14:46:41 2013 +0100

tools: add embeddingareasize arg to pvcreate and vgconvert

To create an Embedding Area during PV creation (pvcreate or as part of
the vgconvert operation), we need to define the Embedding Area size.
The Embedding Area start will be calculated automatically by the tools.

This patch adds --embeddingareasize argument to pvcreate and vgconvert.
---
 tools/args.h      |    1 +
 tools/commands.h  |   15 +++++++++------
 tools/toollib.c   |   14 ++++++++++++++
 tools/vgconvert.c |   15 +++++++++++++++
 4 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index b140cdb..08ace69 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -26,6 +26,7 @@ arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
+arg(embeddingareasize_ARG, '\0', "embeddingareasize", size_mb_arg, 0)
 arg(norestorefile_ARG, '\0', "norestorefile", NULL, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 32d3c96..dedba54 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -540,6 +540,7 @@ xx(pvcreate,
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--pvmetadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--embeddingareasize EmbeddingAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
@@ -551,10 +552,10 @@ xx(pvcreate,
    "\t[--version] " "\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
-   dataalignment_ARG, dataalignmentoffset_ARG, force_ARG, test_ARG,
-   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG,
-   metadatasize_ARG, metadataignore_ARG, norestorefile_ARG,
-   physicalvolumesize_ARG, pvmetadatacopies_ARG,
+   dataalignment_ARG, dataalignmentoffset_ARG, embeddingareasize_ARG,
+   force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG,
+   metadatacopies_ARG, metadatasize_ARG, metadataignore_ARG,
+   norestorefile_ARG, physicalvolumesize_ARG, pvmetadatacopies_ARG,
    restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
 
 xx(pvdata,
@@ -797,13 +798,15 @@ xx(vgconvert,
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--pvmetadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--embeddingareasize EmbeddingAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG, metadatacopies_ARG,
-   pvmetadatacopies_ARG, metadatasize_ARG )
+   force_ARG, test_ARG, labelsector_ARG, embeddingareasize_ARG,
+   metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
+   metadatasize_ARG )
 
 xx(vgcreate,
    "Create a volume group",
diff --git a/tools/toollib.c b/tools/toollib.c
index 3717bde..7043ea4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1413,6 +1413,13 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!(cmd->fmt->features & FMT_EAS) &&
+	    arg_count(cmd, embeddingareasize_ARG)) {
+		log_error("Embedding area parameters only "
+			  "apply to text format.");
+		return 0;
+	}
+
 	if (arg_count(cmd, pvmetadatacopies_ARG) &&
 	    arg_int_value(cmd, pvmetadatacopies_ARG, -1) > 2) {
 		log_error("Metadatacopies may only be 0, 1 or 2");
@@ -1482,6 +1489,11 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (arg_sign_value(cmd, embeddingareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Embedding area size may not be negative");
+		return 0;
+	}
+
 	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
 	if (!pp->pvmetadatasize)
 		pp->pvmetadatasize = find_config_tree_int(cmd,
@@ -1494,6 +1506,8 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 						   "metadata/pvmetadatacopies",
 						   DEFAULT_PVMETADATACOPIES);
 
+	pp->rp.ea_size = arg_uint64_value(cmd, embeddingareasize_ARG, pp->rp.ea_size);
+
 	return 1;
 }
 
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 85f68f2..3671767 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -63,6 +63,15 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 					     DEFAULT_PVMETADATACOPIES);
 	}
 
+	if (cmd->fmt->features & FMT_EAS) {
+		if (arg_sign_value(cmd, embeddingareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Embedding area size may not be negative");
+			return EINVALID_CMD_LINE;
+		}
+
+		rp.ea_size = arg_uint64_value(cmd, embeddingareasize_ARG, UINT64_C(0));
+	}
+
 	if (!archive(vg)) {
 		log_error("Archive of \"%s\" metadata failed.", vg_name);
 		return ECMD_FAILED;
@@ -227,6 +236,12 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (!(cmd->fmt->features & FMT_EAS) &&
+		arg_count(cmd, embeddingareasize_ARG)) {
+		log_error("Embedding area parameters only apply to text format");
+		return EINVALID_CMD_LINE;
+	}
+
 	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &vgconvert_single);
 }


