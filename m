From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Feb 2017 18:44:42 +0000 (UTC)
Subject: master - lvconvert: handle old arg quirk when combining snapshot
Message-ID: <20170215184442.CC69B601A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=286d39ee3c4334e9ce0609d9136dfd6b5d6bf34a
Commit:        286d39ee3c4334e9ce0609d9136dfd6b5d6bf34a
Parent:        d3af0e7528dbba30824379fc98cb4db437559ad5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 12:40:35 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 12:40:35 2017 -0600

lvconvert: handle old arg quirk when combining snapshot

The old ad hoc arg parsing when combining a split snapshot
allowed the first lv to have a vgname, but not the second.
Since lvconvert now uses the standard arg parsing in
process_each_lv(), the old one-off behavior requires a
work around.
---
 tools/lvconvert.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 502d614..a2ad115 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3649,6 +3649,43 @@ static int _lvconvert_combine_split_snapshot_single(struct cmd_context *cmd,
 
 int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
+	const char *vgname = NULL;
+	const char *lvname1;
+	const char *lvname2;
+	char *vglv;
+	int vglv_sz;
+
+	/*
+	 * Hack to accomodate an old parsing quirk that allowed the
+	 * the VG name to be attached to only the LV in arg pos 1,
+	 * i.e. lvconvert -s vgname/lvname lvname
+	 *
+	 * The LV name in arg pos 2 is the one that is processed
+	 * by process_each_lv().  If that LV has no VG name, but
+	 * the first LV does, then copy the VG name from arg pos 1
+	 * and add it to the LV name in arg pos 2 so that the
+	 * standard arg parsing in process_each_lv will find it.
+	 *
+	 * This is the only instance in all commands.
+	 */
+
+	lvname1 = cmd->position_argv[0];
+	lvname2 = cmd->position_argv[1];
+
+	if (strstr("/", lvname1) && !strstr("/", lvname2) && !getenv("LVM_VG_NAME")) {
+		if (!validate_lvname_param(cmd, &vgname, &lvname1))
+			return_ECMD_FAILED;
+
+		vglv_sz = strlen(vgname) + strlen(lvname2) + 2;
+		if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
+		    dm_snprintf(vglv, vglv_sz, "%s/%s", vgname, lvname2) < 0) {
+       			log_error("vg/lv string alloc failed.");
+			return_ECMD_FAILED;
+		}
+
+		cmd->position_argv[1] = vglv;
+	}
+
 	return process_each_lv(cmd, 1, cmd->position_argv + 1, NULL, NULL, READ_FOR_UPDATE,
 			       NULL, NULL, &_lvconvert_combine_split_snapshot_single);
 }


