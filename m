From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jun 2020 17:31:45 +0000 (GMT)
Subject: master - fix bad result from _cache_min_metadata_size
Message-ID: <20200610173145.0A13F388C030@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=712c9efbf6104a863b610a006e72d7da8336fa7e
Commit:        712c9efbf6104a863b610a006e72d7da8336fa7e
Parent:        48c1a295a294fefa0886885f13604f134ceaf406
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 10 16:57:12 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 10 12:17:34 2020 -0500

fix bad result from _cache_min_metadata_size

fixes regression from switching to use _cache_min_metadata_size
(commit c08704cee7e34a96fdaa453faf900683283e8691) which returns
a bogus value when the cachevol size is 8MB.
---
 lib/metadata/cache_manip.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 49b385052..a786e8bac 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -1094,6 +1094,10 @@ int cache_vol_set_params(struct cmd_context *cmd,
 	if (!meta_size) {
 		meta_size = _cache_min_metadata_size(pool_lv->size, chunk_size);
 
+		/* fix bad value from _cache_min_metadata_size */
+		if (meta_size > (pool_lv->size / 2))
+			meta_size = pool_lv->size / 2;
+
 		if (meta_size < min_meta_size)
 			meta_size = min_meta_size;
 


