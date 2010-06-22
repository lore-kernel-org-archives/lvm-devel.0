From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:06:07 -0400
Subject: [PATCH 34/35] Add --vgmetadatacopies to vgsplit man page and command.
In-Reply-To: <1277175968-9661-34-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-26-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-27-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-28-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-29-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-30-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-31-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-32-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-33-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-34-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-35-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/commands.h |    3 ++-
 tools/vgsplit.c  |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 8f5ff3a..aa012a7 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1007,6 +1007,7 @@ xx(vgsplit,
    "\t[-h|--help] " "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
+   "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
    "\t[-t|--test] " "\n"
@@ -1017,7 +1018,7 @@ xx(vgsplit,
 
    alloc_ARG, autobackup_ARG, clustered_ARG,
    maxlogicalvolumes_ARG, maxphysicalvolumes_ARG,
-   metadatatype_ARG, name_ARG, test_ARG)
+   metadatatype_ARG, vgmetadatacopies_ARG, name_ARG, test_ARG)
 
 xx(version,
    "Display software and driver version information",
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 1fa3d00..988c334 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -272,7 +272,8 @@ static int new_vg_option_specified(struct cmd_context *cmd)
 	return(arg_count(cmd, clustered_ARG) ||
 	       arg_count(cmd, alloc_ARG) ||
 	       arg_count(cmd, maxphysicalvolumes_ARG) ||
-	       arg_count(cmd, maxlogicalvolumes_ARG));
+	       arg_count(cmd, maxlogicalvolumes_ARG) ||
+	       arg_count(cmd, vgmetadatacopies_ARG));
 }
 
 int vgsplit(struct cmd_context *cmd, int argc, char **argv)
@@ -382,7 +383,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		    !vg_set_max_lv(vg_to, vp_new.max_lv) ||
 		    !vg_set_max_pv(vg_to, vp_new.max_pv) ||
 		    !vg_set_alloc_policy(vg_to, vp_new.alloc) ||
-		    !vg_set_clustered(vg_to, vp_new.clustered))
+		    !vg_set_clustered(vg_to, vp_new.clustered) ||
+		    !vg_set_mda_copies(vg_to, vp_new.metadata_copies))
 			goto_bad;
 	}
 
-- 
1.6.0.6


