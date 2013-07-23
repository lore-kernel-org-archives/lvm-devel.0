From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 23 Jul 2013 19:46:46 +0000 (UTC)
Subject: master - Clean-up: Addressing a few FIXME's
Message-ID: <20130723194646.A7669610D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d00d45a8b609d50302c94a0fff20849f0cc13a48
Commit:        d00d45a8b609d50302c94a0fff20849f0cc13a48
Parent:        a2b51476007aae91acfc121a7fd2ce04f3b08781
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jul 23 14:46:22 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jul 23 14:46:22 2013 -0500

Clean-up:  Addressing a few FIXME's

Three fixme's addressed in this commit:
1) lib/metadata/lv_manip.c:_calc_area_multiple() - this could be
   safely changed to a comment explaining that currently because
   RAID10 can only have a 2-way mirror, we don't need to know the
   number of stripes.  However, we will need to know that in the
   future if RAID10 is to support more than 2-way mirroring.

2) lib/metadata/mirror.c:_delete_lv() - should have been calling
   _activate_lv_like_model() with 'mirror_lv'.  This is because
   'mirror_lv' is the LV that the overall operation is being
   performed on.  We need to use this LV as the basis for
   determining whether to activate locally, or across the
   cluster, etc.

3) tools/lvcreate.c:_lvcreate_params() - Minor clean-up.  If
   '-m 0' is given, treat it as though the mirroring argument
   was not given (i.e. as though the requested segment type
   was 'stripe' and not mirror).
---
 lib/metadata/lv_manip.c |   11 ++++++++---
 lib/metadata/mirror.c   |    3 +--
 tools/lvcreate.c        |    7 +++----
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9284c7b..8fea33d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -846,7 +846,8 @@ struct alloc_handle {
 };
 
 static uint32_t _calc_area_multiple(const struct segment_type *segtype,
-				    const uint32_t area_count, const uint32_t stripes)
+				    const uint32_t area_count,
+				    const uint32_t stripes)
 {
 	if (!area_count)
 		return 1;
@@ -868,9 +869,13 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
 		return area_count - segtype->parity_devs;
 	}
 
-	/* RAID10 - only has 2-way mirror right now */
+	/*
+	 * RAID10 - only has 2-way mirror right now.
+	 *          If we are to move beyond 2-way RAID10, then
+	 *          the 'stripes' argument will always need to
+	 *          be given.
+	 */
 	if (!strcmp(segtype->name, "raid10")) {
-		// FIXME: I'd like the 'stripes' arg always given
 		if (!stripes)
 			return area_count / 2;
 		return stripes;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 4f36e0d..8748d89 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -434,8 +434,7 @@ static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *l
 		}
 	}
 
-	// FIXME: shouldn't the activation type be based on mirror_lv, not lv?
-	if (!_activate_lv_like_model(lv, lv))
+	if (!_activate_lv_like_model(mirror_lv, lv))
 		return_0;
 
 	/* FIXME Is this superfluous now? */
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2e8c65f..8564613 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -735,10 +735,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-// FIXME -m0 implies *striped*
-
-	/* Set default segtype */
-	if (arg_count(cmd, mirrors_ARG))
+	/* Set default segtype - remember, '-m 0' implies stripe. */
+	if (arg_count(cmd, mirrors_ARG) &&
+	    arg_uint_value(cmd, mirrors_ARG, 0))
 		if (arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ?
 				   stripes_long_ARG : stripes_ARG, 1) > 1) {
 			segtype_str = find_config_tree_str(cmd, global_raid10_segtype_default_CFG, NULL);;


