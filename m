From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:19 +0000 (UTC)
Subject: master - lvconvert: fix vg parameter
Message-ID: <20160225223619.A812560AA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=abd9618dd8b77ca1974074ae76fa6a08f1a687d9
Commit:        abd9618dd8b77ca1974074ae76fa6a08f1a687d9
Parent:        a68e601886e1c9b78345b4c33ce366451e2fe184
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 20:40:28 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:30:24 2016 +0100

lvconvert: fix vg parameter

Since we want to read env LVM_VG_NAME vg names,
we cannot just check LV names which do contain '/'.

So before the patch commands like:

> lvconvert --repair vg

Before:

Please provide a valid volume group name

After:
Path required for Logical Volume "vg".
Please provide a valid volume group name

> LVM_VG_NAME=vg lvconvert --repair vg

Before:
Please provide a valid volume group name

After:
Can't find LV vg in VG vg
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 524fea4..250f3f1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Improve support for env LVM_VG_NAME for reference VG name in lvconvert.
   Fix regresion when lvresize accepted zero sizes (2.02.141).
   Always warn user about PV in use even when pvremove uses --force --force.
   Use uninitilized pool header detection in all cases.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e7394c0..3ec6d59 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -173,8 +173,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->lv_split_name))
 		return_0;
 
-	if (strchr(lp->lv_name_full, '/') &&
-	    (vg_name = extract_vgname(cmd, lp->lv_name_full)) &&
+	if ((vg_name = extract_vgname(cmd, lp->lv_name_full)) &&
 	    lp->vg_name && strcmp(vg_name, lp->vg_name)) {
 		log_error("Please use a single volume group name "
 			  "(\"%s\" or \"%s\")", vg_name, lp->vg_name);


