From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 Nov 2012 11:16:57 +0000 (UTC)
Subject: master - lv_manip: fix regresion from bf2741376d4
Message-ID: <20121121111657.BE7D54979@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=400f6442861c6832f5f89d6e40e668517895b50d
Commit:        400f6442861c6832f5f89d6e40e668517895b50d
Parent:        d5697b29ee009104a4ed91f79543e22cc8c8d2c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 21 09:46:18 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 21 12:15:09 2012 +0100

lv_manip: fix regresion from bf2741376d4

Commit bf2741376d47411994d4065863acab8e405ff5c7 started to use
lv_is_active() instead of call for lv_info & info.exists so
we cover also cluster activated devices.
For snapshost the conversion was not correct and introduced
regression by blocking creation of snapshot of inactive LV.

Fix it by assigning lv_is_active() directly.
Note: we still have minor issue to fix - to make
lv_is_???? function able to return error states since
lv_info() may fail.
---
 lib/metadata/lv_manip.c      |   10 ++--------
 test/shell/lvcreate-usage.sh |    2 ++
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index dc315ac..35a75ff 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4367,14 +4367,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 			}
 
-			if (!lv_is_active(org)) {
-				log_error("Check for existence of active snapshot "
-					  "origin '%s' failed.", org->name);
-				return NULL;
-			}
-			origin_active = 1;
-
-			if (vg_is_clustered(vg) &&
+			if ((origin_active = lv_is_active(org)) &&
+			    vg_is_clustered(vg) &&
 			    !lv_is_active_exclusive_locally(org)) {
 				log_error("%s must be active exclusively to"
 					  " create snapshot", org->name);
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index ddde401..c9c906a 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -64,6 +64,8 @@ lvcreate -l1 -n $lv3 $vg
 not lvcreate -l1 -n $lv4 $vg
 
 lvremove -ff $vg/$lv3
+# check snapshot of inactive origin
+lvchange -an $vg/$lv1
 lvcreate -l1 -s -n $lv3 $vg/$lv1
 not lvcreate -l1 -n $lv4 $vg
 not lvcreate -l1 -m1 -n $lv4 $vg


