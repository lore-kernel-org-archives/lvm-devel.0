From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Nov 2017 12:48:43 -0500
Subject: master - lvconvert: prevent combining split snapshots in shared vg
Message-ID: <201711211748.vALHmhs2003988@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=175d06a92940dda5de3a7631e3d27cd6828a16be
Commit:        175d06a92940dda5de3a7631e3d27cd6828a16be
Parent:        ea0463791dcc68082ecf0b6b6681e82becaffb40
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 21 11:45:49 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 21 11:45:49 2017 -0600

lvconvert: prevent combining split snapshots in shared vg

splitting snapshots was already prevented.
---
 tools/lvconvert.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index eab7e6d..ed1a130 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3828,6 +3828,11 @@ static int _lvconvert_combine_split_snapshot_single(struct cmd_context *cmd,
 {
 	const char *origin_name = cmd->position_argv[0];
 
+	if (is_lockd_type(lv->vg->lock_type)) {
+		log_error("Unable to combine split snapshots in VG with lock_type %s", lv->vg->lock_type);
+		return ECMD_FAILED;
+	}
+
 	/* If origin_name includes VG name, the VG name is removed. */
 	if (!validate_lvname_param(cmd, &lv->vg->name, &origin_name))
 		return_ECMD_FAILED;


