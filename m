From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Oct 2017 12:29:04 -0400
Subject: master - raid: setup LV size earlier
Message-ID: <201710301629.v9UGT4rp010051@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b6391538c53e19a6fccdb4e3638ba9dd221819a
Commit:        2b6391538c53e19a6fccdb4e3638ba9dd221819a
Parent:        3efd1f9c6e1e63c70d12cf3bc2f8eadcba47d7e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 30 17:23:56 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 30 17:23:56 2017 +0100

raid: setup LV size earlier

New validation code which does require to not store LV with no size
(no segments) revealed this size setup code needs to happen
earlier.
---
 lib/metadata/lv_manip.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a3634ac..f0e492b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4028,6 +4028,15 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		fa += stripes;
 	}
 
+	seg->len += extents;
+	if (seg_is_raid(seg))
+		seg->area_len = seg->len;
+	else
+		seg->area_len += extents / area_multiple;
+
+	if (!_setup_lv_size(lv, lv->le_count + extents))
+		return_0;
+
 	if (clear_metadata) {
 		/*
 		 * We must clear the metadata areas upon creation.
@@ -4092,15 +4101,6 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 			lv_set_hidden(seg_metalv(seg, s));
 	}
 
-	seg->len += extents;
-	if (seg_is_raid(seg))
-		seg->area_len = seg->len;
-	else
-		seg->area_len += extents / area_multiple;
-
-	if (!_setup_lv_size(lv, lv->le_count + extents))
-		return_0;
-
 	return 1;
 }
 


