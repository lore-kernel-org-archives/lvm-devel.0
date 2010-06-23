From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 23 Jun 2010 12:14:06 -0400
Subject: [PATCH] Ensure --metadatacopies parameter gets interpreted based on command.
Message-ID: <1277309646-24343-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Now that we have both --pvmetadatacopies and --vgmetadatacopies,
we need to make sure --metadatacopies gets interpreted correctly.

For pv commands, --metadatacopies should imply --pvmetadatacopies,
and for vg commands, --vgmetadatacopies.

Note: this will change the behavior of vgcreate with --metadatacopies
to be a synonym for --vgmetadatacopies.  Previously, --metadatacopies
would apply to any PVs given with vgcreate that needed an implicit
pvcreate.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvmcmdline.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6a5479d..45762b5 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -827,8 +827,13 @@ static int _get_settings(struct cmd_context *cmd)
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, allocatable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG) ||
-	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG) ||
-	    !_merge_synonym(cmd, metadatacopies_ARG, pvmetadatacopies_ARG))
+	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG))
+		return EINVALID_CMD_LINE;
+
+	if ((!strncmp(cmd->command->name, "pv", 2) &&
+	    !_merge_synonym(cmd, metadatacopies_ARG, pvmetadatacopies_ARG)) ||
+	    (!strncmp(cmd->command->name, "vg", 2) &&
+	     !_merge_synonym(cmd, metadatacopies_ARG, vgmetadatacopies_ARG)))
 		return EINVALID_CMD_LINE;
 
 	/* Zero indicates success */
-- 
1.6.0.6


