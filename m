From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:54:33 +0000 (UTC)
Subject: master - thin: improve swapping of identifiers
Message-ID: <20150911195433.3D00860F52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fda853b573920ccefda23ad97f54d7b4dafaa9f1
Commit:        fda853b573920ccefda23ad97f54d7b4dafaa9f1
Parent:        280a6275ce7262baae0062c58a63b910bc16327d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 20:56:53 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:51:11 2015 +0200

thin: improve swapping of identifiers

Since we may want to swap names when LVs are complex types, we cannot
avoid doing full renames on both LV stacks.
Temporarily use 'pvmove_tmeta' as unused name to prevent validation troubles.
---
 WHATS_NEW              |    1 +
 tools/lvconvert.c      |    4 ++--
 tools/lvconvert_poll.c |   13 +++++++++----
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 163077f..2c444c7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Swapping of LV identifiers handles more complex LVs.
   Use passed list of PVS when allocating space in lvconvert --thinpool.
   Disallow usage of --stripe and --stripesize when creating cache pool.
   Warn user when caching raid or thin pool data LV.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6b8f7aa..b5658f2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2489,14 +2489,14 @@ deactivate_pmslv:
 	if (!detach_pool_metadata_lv(first_seg(pool_lv), &mlv))
 		return_0;
 
+	/* Swap _pmspare and _tmeta name */
 	if (!swap_lv_identifiers(cmd, mlv, pmslv))
 		return_0;
 
-	/* Used _pmspare will become _tmeta */
 	if (!attach_pool_metadata_lv(first_seg(pool_lv), pmslv))
 		return_0;
 
-	/* Used _tmeta will become visible  _meta%d */
+	/* Used _tmeta (now _pmspare) becomes _meta%d */
 	if (!lv_rename_update(cmd, mlv, pms_path, 0))
 		return_0;
 
diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index e3a3709..1b230bc 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -44,15 +44,20 @@ int swap_lv_identifiers(struct cmd_context *cmd,
 			struct logical_volume *a, struct logical_volume *b)
 {
 	union lvid lvid;
-	const char *name;
+	const char *aname = a->name, *bname = b->name;
 
 	lvid = a->lvid;
 	a->lvid = b->lvid;
 	b->lvid = lvid;
 
-	name = a->name;
-	a->name = b->name;
-	if (!lv_rename_update(cmd, b, name, 0))
+	/* rename temporarily to 'unused' name */
+	if (!lv_rename_update(cmd, a, "pmove_tmeta", 0))
+		return_0;
+	/* name rename 'b' to unused name of 'a' */
+	if (!lv_rename_update(cmd, b, aname, 0))
+		return_0;
+	/* finish name swapping */
+	if (!lv_rename_update(cmd, a, bname, 0))
 		return_0;
 
 	return 1;


