From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 10 Sep 2020 21:56:20 +0000 (GMT)
Subject: master - cleanup: comment typo
Message-ID: <20200910215620.3B9AD398544B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=678951f635616fc54896717af1183092a0556a3f
Commit:        678951f635616fc54896717af1183092a0556a3f
Parent:        e7bd3ba22dc6736654bbfe235924a64a511bcf8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 22:38:13 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 23:55:03 2020 +0200

cleanup: comment typo

---
 lib/metadata/thin_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 0704f2bc3..588707961 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -224,7 +224,7 @@ int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 int pool_metadata_min_threshold(const struct lv_segment *pool_seg)
 {
 	/*
-	 * Hardcoded minimal requirment for thin pool target.
+	 * Hardcoded minimal requirement for thin pool target.
 	 *
 	 * In the metadata LV there should be minimum from either 4MiB of free space
 	 * or at least 25% of free space, which applies when the size of thin pool's


