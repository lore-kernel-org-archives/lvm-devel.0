From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:49 +0100
Subject: [PATCH 02/12] Query before removing inactive snapshots
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <64d155b8dea0021fda984c0768b2502c9758877d.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the origin is not active - removal of such origin removes
also all connected snapshots.

When we now support 'old' external snapshots with thin volumes,
removal of pool will not only drop all thin volumes, but as
a consequence also all snapshots - which might be seen a bit
unexpected for the user - so add a query to confirm such action.

lvremove -f will skip the prompt.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c  |   12 +++++++++++-
 test/t-lvcreate-usage.sh |    2 +-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c323921..77ea830 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3248,7 +3248,17 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	}
 
 	if (lv_is_origin(lv)) {
-		/* remove snapshot LVs first */
+		/* Remove snapshot LVs first */
+		if ((force == PROMPT) &&
+		    /* Active snapshot already needs to confirm each active LV */
+		    !lv_is_active(lv) &&
+		    yes_no_prompt("Removing origin %s will also remove %u "
+				  "snapshots(s). OK? [y/n]: ",
+				  lv->name, lv->origin_count) == 'n') {
+			log_error("Logical volume %s not removed.", lv->name);
+			return 0;
+		}
+
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
 										  origin_list)->cow,
diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 595e1ad..b8e6967 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -122,7 +122,7 @@ lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
 lvrename $vg/$lv1 $vg/$lv2
 lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
 lvchange -a n $vg/$lv1
-lvremove $vg/$lv1
+lvremove -ff $vg/$lv1
 lvremove -ff $vg
 
 # readahead default (auto), none, #, auto
-- 
1.7.7.3


