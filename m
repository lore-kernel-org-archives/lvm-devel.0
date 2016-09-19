From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Sep 2016 12:01:47 +0000 (UTC)
Subject: master - debug: cleanup backtrace after log_error
Message-ID: <20160919120147.6FCAA6053F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72abf692e5b4f503ca9b52725df020342075c32f
Commit:        72abf692e5b4f503ca9b52725df020342075c32f
Parent:        a029123679e183d410189dd90e17d6f5b590a35b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 16 14:42:37 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 19 14:00:56 2016 +0200

debug: cleanup backtrace after log_error

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e714f0b..5adf81e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7156,7 +7156,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (!lp->extents && !seg_is_thin_volume(lp)) {
 		log_error(INTERNAL_ERROR "Unable to create new logical volume with no extents.");
-		return_NULL;
+		return NULL;
 	}
 
 	if ((seg_is_pool(lp) || seg_is_cache(lp)) &&


