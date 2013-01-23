From: David Teigland <teigland@redhat.com>
Date: Wed, 23 Jan 2013 11:53:40 -0500
Subject: [PATCH] vgreduce: only process specified vg when pv is identified by tag
Message-ID: <20130123165339.GA31607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix vgreduce to only process specified vg when pv is identified by tag.
process_each_pv was attempting to process all vgs in this case.

---
 WHATS_NEW       | 1 +
 tools/toollib.c | 9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eb8a4a0..53df906 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix vgreduce to only process specified vg when pv is identified by tag.
   Fix blkdeactivate to handle nested mountpoints and mangled mount paths.
   Set locales with LC_ALL instead of lower priority LANG variable.
   Fix a crash-inducing race condition in lvmetad.
diff --git a/tools/toollib.c b/tools/toollib.c
index 669d772..0e6979a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -801,7 +801,14 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			if (sigint_caught())
 				goto out;
 		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 1)) &&
+		if (!dm_list_empty(&tags) && vg) {
+			ret = process_each_pv_in_vg(cmd, vg, &tags, handle,
+						    process_single_pv);
+			if (ret > ret_max)
+				ret_max = ret;
+			if (sigint_caught())
+				goto out;
+		} else if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 1)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				vg = vg_read(cmd, sll->str, NULL, flags);
-- 
1.8.1.rc1.5.g7e0651a


