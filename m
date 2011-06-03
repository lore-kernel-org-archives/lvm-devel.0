From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:26 +0200
Subject: [PATCH 08/11] Code move vg_mark_partial up in stack
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <fab66122645346976588f65adc81fd36b4b1a37a.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's useful to keep the partial flag cached - so just move the call
for vg_mark_partil_lvs() into import_vg_from_config_tree().

This patch should not present any functional change.

Note: It is rather temporal solution - proper place is inside the
'read' call back - but needs some more discussion.
For now using this minor hack.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/import.c |    6 ++++++
 lib/metadata/metadata.c  |    5 -----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index aa8c807..83e781b 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -136,6 +136,7 @@ struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
 {
 	struct volume_group *vg = NULL;
 	struct text_vg_version_ops **vsn;
+	int vg_missing;
 
 	_init_text_import();
 
@@ -148,6 +149,11 @@ struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
 		 */
 		if (!(vg = (*vsn)->read_vg(fid, cft, 1)))
 			stack;
+		else if ((vg_missing = vg_missing_pv_count(vg))) {
+			log_verbose("There are %d physical volumes missing.",
+				    vg_missing);
+			vg_mark_partial_lvs(vg, 1);
+		}
 		break;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index dc00579..9e235a1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2867,11 +2867,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		else	/* Inconsistent but we can't repair it */
 			correct_vg->status &= ~INCONSISTENT_VG;
 
-		if (vg_missing_pv_count(correct_vg)) {
-			log_verbose("There are %d physical volumes missing.",
-				    vg_missing_pv_count(correct_vg));
-			vg_mark_partial_lvs(correct_vg, 1);
-		}
 		return correct_vg;
 	} else {
 		free_vg(correct_vg);
-- 
1.7.5.2


