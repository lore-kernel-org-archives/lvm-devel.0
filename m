From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:30 +0000 (UTC)
Subject: dev-prajnoha-selout - coverity: error for undefined origin
Message-ID: <20140509065630.E1E7C60774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d11617864a6434c3775e1fbc8c55af6d3ae5dc57
Commit:        d11617864a6434c3775e1fbc8c55af6d3ae5dc57
Parent:        a8042f33d0ee7f71952d65f2cc408775fa440c8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 11:14:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:16:18 2014 +0200

coverity: error for undefined origin

If we would have been missing origin here, it would
be an internal error - since these values are validated
earlier.
---
 lib/metadata/lv_manip.c |    4 ++++
 tools/lvcreate.c        |    5 ++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6817831..b47e2d2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5993,6 +5993,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 							    "cache-pool")))
 			return_0;
 	} else if (seg_is_thin(lp) && lp->snapshot) {
+		if (!lp->origin) {
+			log_error(INTERNAL_ERROR "Origin LV is not defined.");
+			return 0;
+		}
 		if (!(org = find_lv(vg, lp->origin))) {
 			log_error("Couldn't find origin volume '%s'.",
 				  lp->origin);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6a9264a..0e009b1 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -304,7 +304,10 @@ static int _determine_cache_argument(struct volume_group *vg,
 			  lp->segtype->name);
 		return 0;
 	}
-
+	if (!lp->origin) {
+		log_error(INTERNAL_ERROR "Origin LV is not defined.");
+		return 0;
+	}
 	if (!(lvl = find_lv_in_vg(vg, lp->origin))) {
 		log_error("LV %s not found in Volume group %s.",
 			  lp->origin, vg->name);


