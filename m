From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 22 Mar 2012 16:01:34 +0100
Subject: [PATCH] Allow vgname/lvname name specification in lvconvert --splitmirrors
Message-ID: <4F6B3ECE.50804@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Before:
devel/~ # lvconvert --splitmirrors 1 -n vg/splitted_one vg/mirrored_one
  Internal error: LV name vg/splitted_one has invalid form.
  Intermediate VG metadata write failed.

After:
devel/~ # lvconvert --splitmirrors 1 -n vg/splitted_one vg/mirrored_one
  Logical volume mirrored_one converted.

devel/~ # lvconvert --splitmirrors 1 -n blabla/splitted_one vg/mirrored_one
  Please use a single volume group name ("vg" or "blabla")
  Run `lvconvert --help' for more information.

...should make rhbz #796602 happy (lvcreate/lvrename already accepts
vgname/lvname for a new volume name).

Peter
---
 tools/lvconvert.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 654e115..2071f08 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -173,9 +173,19 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		}
 
 		lp->lv_split_name = arg_value(cmd, name_ARG);
-		if (lp->lv_split_name &&
-		    !apply_lvname_restrictions(lp->lv_split_name))
-			return_0;
+		if (lp->lv_split_name) {
+			if (strchr(lp->lv_split_name, '/')) {
+				if (!(lp->vg_name = extract_vgname(cmd, lp->lv_split_name)))
+					return_0;
+
+				/* Strip VG from lv_split_name */
+				if ((tmp_str = strrchr(lp->lv_split_name, '/')))
+					lp->lv_split_name = tmp_str + 1;
+			}
+
+			if (!apply_lvname_restrictions(lp->lv_split_name))
+				return_0;
+		}
 
 		lp->keep_mimages = 1;
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);


