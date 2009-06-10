From: Milan Broz <mbroz@redhat.com>
Date: Wed, 10 Jun 2009 17:05:27 +0200
Subject: [PATCH] Allow metadata correction even when PVs are missing
Message-ID: <4A2FCBB7.5000203@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow metadata correction even when PVs are missing.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d0b7652..2ca12da 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1835,6 +1835,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	int inconsistent_vgid = 0;
 	int inconsistent_pvs = 0;
 	unsigned use_precommitted = precommitted;
+	unsigned saved_handles_missing_pvs = cmd->handles_missing_pvs;
 	struct dm_list *pvids;
 	struct pv_list *pvl, *pvl2;
 	struct dm_list all_pvs;
@@ -2076,11 +2077,14 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		log_warn("WARNING: Inconsistent metadata found for VG %s - updating "
 			 "to use version %u", vgname, correct_vg->seqno);
 
+		cmd->handles_missing_pvs = 1;
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
 			vg_release(correct_vg);
+			cmd->handles_missing_pvs = saved_handles_missing_pvs;
 			return NULL;
 		}
+		cmd->handles_missing_pvs = saved_handles_missing_pvs;
 
 		if (!vg_commit(correct_vg)) {
 			log_error("Automatic metadata correction commit "



