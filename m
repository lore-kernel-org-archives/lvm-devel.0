From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Apr 2014 11:55:13 +0000 (UTC)
Subject: master - pvcreate: fix ignored --dataalignment/dataalignment offset for pvcreate --restorefile
Message-ID: <20140410115513.CF8AF60D76@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c79556f4f836118516a2f1a15056f81e3fc52f6
Commit:        6c79556f4f836118516a2f1a15056f81e3fc52f6
Parent:        b45d2768a858cc65a6770eed4db99f8b82b6353b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 10 13:43:46 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 10 13:43:46 2014 +0200

pvcreate: fix ignored --dataalignment/dataalignment offset for pvcreate --restorefile

There were two bugs before when using pvcreate --restorefile together
with data alignment and its offset specified:

  - the --dataalignment was always ignored due to missing braces in the
    code when validating the divisibility of supplied --dataalignment
    argument with pe_start which we're just restoring:

	if (pp->rp.pe_start % pp->data_alignment)
		log_warn("WARNING: Ignoring data alignment %" PRIu64
			 " incompatible with --restorefile value (%"
			 PRIu64").", pp->data_alignment, pp->rp.pe_start);
        pp->data_alignment = 0

    The pp->data_alignment should be zeroed only if the pe_start is not
    divisible with data_alignment.

  - the check for compatibility of restored pe_start was incorrect too
    since it did not properly count with the dataalignmentoffset that
    could be supplied together with dataalignment

The proper formula is:

  X * dataalignment + dataalignmentoffset == pe_start

So it should be:

  if ((pp->rp.pe_start % pp->data_alignment) != pp->data_alignment_offset) {
	...ignore supplied dataalignment and dataalignment offset...
  }
---
 WHATS_NEW       |    1 +
 tools/toollib.c |   22 +++++++++-------------
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ebb0f09..5023ba2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix ignored --dataalignment/dataalignment offset for pvcreate --restorefile.
   Fix lost information about bootloader area when using lvmetad.
   Don't require --major to be specified when using -My option on kernels > 2.4.
   Add configure --disable-thin_check_needs_check to support old thin_check.
diff --git a/tools/toollib.c b/tools/toollib.c
index 6b68f55..052c141 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1580,14 +1580,6 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (pp->data_alignment && pp->rp.pe_start != PV_PE_START_CALC) {
-		if (pp->rp.pe_start % pp->data_alignment)
-			log_warn("WARNING: Ignoring data alignment %" PRIu64
-				 " incompatible with --restorefile value (%"
-				 PRIu64").", pp->data_alignment, pp->rp.pe_start);
-		pp->data_alignment = 0;
-	}
-
 	if (arg_sign_value(cmd, dataalignmentoffset_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume data alignment offset may not be negative");
 		return 0;
@@ -1599,11 +1591,15 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (pp->data_alignment_offset && pp->rp.pe_start != PV_PE_START_CALC) {
-		log_warn("WARNING: Ignoring data alignment offset %" PRIu64
-			 " incompatible with --restorefile value (%"
-			 PRIu64").", pp->data_alignment_offset, pp->rp.pe_start);
-		pp->data_alignment_offset = 0;
+	if ((pp->data_alignment + pp->data_alignment_offset) &&
+	    (pp->rp.pe_start != PV_PE_START_CALC)) {
+		if ((pp->rp.pe_start % pp->data_alignment) != pp->data_alignment_offset) {
+			log_warn("WARNING: Ignoring data alignment %" PRIu64
+				 " incompatible with restored pe_start value %" PRIu64").",
+				 pp->data_alignment + pp->data_alignment_offset, pp->rp.pe_start);
+			pp->data_alignment = 0;
+			pp->data_alignment_offset = 0;
+		}
 	}
 
 	if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {


