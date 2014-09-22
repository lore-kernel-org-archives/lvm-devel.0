From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:54 +0000 (UTC)
Subject: dev-dct-process-latest - lvconvert: Restrict use of cache LVs.
Message-ID: <20140922153854.2132D61087@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdb05cc05e3a0eac72b0921cb5eb500891346e12
Commit:        bdb05cc05e3a0eac72b0921cb5eb500891346e12
Parent:        b4f5be76a3b8c9c89719e5d8699033a79c993b6f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 17 16:41:58 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 17 16:41:58 2014 +0100

lvconvert: Restrict use of cache LVs.

Refuse use of -m and -s with cache LVs until full support
can be provided.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1f64d0d..67c6482 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Ensure only supported volume types are used with cache segments.
   Fix inablility to specify cachemode when 'lvconvert'ing to cache-pool.
   Grab cluster lock for active LVs when setting clustered attribute.
   Use va_copy to properly pass va_list through functions.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 93a2be4..295a4e5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1725,6 +1725,12 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_is_cache_type(lv)) {
+		log_error("Mirrors are not yet supported on cache LVs %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	/* Adjust mimage and/or log count */
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,
@@ -2011,6 +2017,12 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_is_cache_type(lv)) {
+		log_error("Snapshots are not yet supported with cache type LVs %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	if (!(org = find_lv(lv->vg, lp->origin_lv_name))) {
 		log_error("Couldn't find origin volume %s.", lp->origin_lv_name);
 		return 0;


