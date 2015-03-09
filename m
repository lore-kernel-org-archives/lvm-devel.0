From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Mar 2015 19:00:56 +0000 (UTC)
Subject: master - vgconvert: Check system ID compatibility.
Message-ID: <20150309190056.B8B5460223@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1334ea214ea1f55173f2ff7e3045cc72a8c4e7c7
Commit:        1334ea214ea1f55173f2ff7e3045cc72a8c4e7c7
Parent:        a8545462349c560cf66362cb3d25b44b7b0e819b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 9 19:01:12 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 9 19:01:12 2015 +0000

vgconvert: Check system ID compatibility.

If system ID is set, don't switch to a format that doesn't support it.
---
 tools/vgconvert.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 50b3e44..3742237 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -94,6 +94,13 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 				return ECMD_FAILED;
 			}
 
+	/* New-style system ID supported? */ 
+	if (vg->system_id && *vg->system_id && (cmd->fmt->features & FMT_SYSTEMID_ON_PVS)) {
+		log_error("Unable to convert VG %s while it has a system ID set (%s).", vg->name,
+			  vg->system_id);
+		return ECMD_FAILED;
+	}
+
 	/* Attempt to change any LVIDs that are too big */
 	if (cmd->fmt->features & FMT_RESTRICTED_LVIDS) {
 		dm_list_iterate_items(lvl, &vg->lvs) {


