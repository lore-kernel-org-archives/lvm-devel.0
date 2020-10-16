From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:43 +0000 (GMT)
Subject: stable-2.02 - lvmcache: use uint32_t for seqno caching
Message-ID: <20201016191043.AEA0838618E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ffe17d2a85bb3fa1a60af28b45bafcf1af5b2d1
Commit:        9ffe17d2a85bb3fa1a60af28b45bafcf1af5b2d1
Parent:        950a9bbde9b1b70848c8bb92f77be2c9ccbe1fec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:48:40 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

lvmcache: use uint32_t for seqno caching

---
 lib/cache/lvmcache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ed605dc0f..2bda26b87 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -60,7 +60,7 @@ struct lvmcache_vginfo {
 	char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
-	int seqno;
+	uint32_t seqno;
 	int independent_metadata_location; /* metadata read from independent areas */
 	int scan_summary_mismatch; /* vgsummary from devs had mismatching seqno or checksum */
 };


