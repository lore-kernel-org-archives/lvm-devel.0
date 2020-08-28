From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:10 +0000 (GMT)
Subject: master - lvmcache: use uint32_t for seqno caching
Message-ID: <20200828195910.C3BCC386F039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93c9055591d8311cb361909f719964cdfa79e209
Commit:        93c9055591d8311cb361909f719964cdfa79e209
Parent:        03f9cd95b4bad1e055ce932742426b0724f607c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:48:40 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

lvmcache: use uint32_t for seqno caching

---
 lib/cache/lvmcache.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b1d05fb07..147d0f1cc 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -42,9 +42,9 @@ struct lvmcache_info {
 	bool mda1_bad;		/* label scan found bad metadata in mda1 */
 	bool mda2_bad;		/* label scan found bad metadata in mda2 */
 	bool summary_seqno_mismatch; /* two mdas on this dev has mismatching metadata */
-	int summary_seqno;      /* vg seqno found on this dev during scan */
-	int mda1_seqno;
-	int mda2_seqno;
+	uint32_t summary_seqno;      /* vg seqno found on this dev during scan */
+	uint32_t mda1_seqno;
+	uint32_t mda2_seqno;
 };
 
 /* One per VG */
@@ -63,7 +63,7 @@ struct lvmcache_vginfo {
 	char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
-	int seqno;
+	uint32_t seqno;
 	bool scan_summary_mismatch; /* vgsummary from devs had mismatching seqno or checksum */
 	bool has_duplicate_local_vgname;   /* this local vg and another local vg have same name */
 	bool has_duplicate_foreign_vgname; /* this foreign vg and another foreign vg have same name */


