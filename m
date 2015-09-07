From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 11:15:18 +0000 (UTC)
Subject: master - libdm: handle pool errors in dm_histogram_to_string()
Message-ID: <20150907111518.7890560AD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f5933ecc1bf792a404e2cdfa8a2eccf66b5b6e1
Commit:        0f5933ecc1bf792a404e2cdfa8a2eccf66b5b6e1
Parent:        e75b4bc2df7ce9bf3b3644fb0e6d9d52467adb8e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 12:01:20 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 12:01:20 2015 +0100

libdm: handle pool errors in dm_histogram_to_string()

---
 libdm/libdm-stats.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 0655ac5..bb26c46 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2222,7 +2222,8 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 	/* Set bounds string to the empty string. */
 	bounds_buf[0] = '\0';
 
-	dm_pool_begin_object(mem, 64);
+	if (!dm_pool_begin_object(mem, 64))
+		return_0;
 
 	for (bin = start; bin <= last; bin++) {
 		if (bounds) {
@@ -2277,9 +2278,13 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 			goto_bad;
 
 		width = minwidth; /* re-set histogram column width. */
-		dm_pool_grow_object(mem, buf, (size_t) len);
+		if (!dm_pool_grow_object(mem, buf, (size_t) len))
+			goto_bad;
 	}
-	dm_pool_grow_object(mem, "\0", 1);
+
+	if (!dm_pool_grow_object(mem, "\0", 1))
+		goto_bad;
+
 	return (const char *) dm_pool_end_object(mem);
 
 bad:


