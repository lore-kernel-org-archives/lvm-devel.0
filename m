From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:53:06 -0400
Subject: [PATCH 35/38] Ensure --metadatacopies parameter gets interpreted based on command.
In-Reply-To: <1277520789-6808-35-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-19-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-20-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-21-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-22-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-23-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-24-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-25-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-26-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-27-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-28-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-29-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-30-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-31-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-32-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-33-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-34-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-35-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-36-git-send-email-dwysocha@redhat.com>
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
pvcreate.  As a result, one small change is needed to one of the nightly
tests - t-vgcreate-usage.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-vgcreate-usage.sh |    2 +-
 tools/lvmcmdline.c       |    9 +++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/test/t-vgcreate-usage.sh b/test/t-vgcreate-usage.sh
index ffdad53..0253cc3 100755
--- a/test/t-vgcreate-usage.sh
+++ b/test/t-vgcreate-usage.sh
@@ -115,7 +115,7 @@ do
     vgremove -f $vg
     pvremove -f $dev1
 done
-not vgcreate -c n --metadatacopies 0 $vg $dev1
+not vgcreate -c n --pvmetadatacopies 0 $vg $dev1
 pvcreate --metadatacopies 1 $dev2
 vgcreate -c n --pvmetadatacopies 0 $vg $dev1 $dev2
 check_pv_field_ $dev1 pv_mda_count 0
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


