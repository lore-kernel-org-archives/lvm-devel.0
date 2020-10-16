From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:11 +0000 (GMT)
Subject: stable-2.02 - cleanup: comment typo
Message-ID: <20201016191111.086F2396EC6B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5066339a5c61c5d5e8cd365071526cdd07ec04c
Commit:        e5066339a5c61c5d5e8cd365071526cdd07ec04c
Parent:        5190e16c30dcf3ed76a756ff0a5e54342f477abd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 22:38:13 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

cleanup: comment typo

---
 lib/metadata/thin_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 3aab29708..02a97d588 100644
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


