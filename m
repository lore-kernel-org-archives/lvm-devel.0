From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:36 -0400
Subject: master - libdm: do not leak FIEMAP extent buffer if pool allocation fails (coverity)
Message-ID: <201703292016.v2TKGasD000839@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc5d67884fd489682c0267002474e9089e368fe2
Commit:        bc5d67884fd489682c0267002474e9089e368fe2
Parent:        13426092e9681d13acfa9eae505b20537c236340
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:37:10 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:30 2017 +0100

libdm: do not leak FIEMAP extent buffer if pool allocation fails (coverity)

---
 libdm/libdm-stats.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index fa865a1..5041d61 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4401,10 +4401,14 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	unsigned long flags = 0;
 	uint64_t *buf;
 
+	/* grow temporary extent table in the pool */
+	if (!dm_pool_begin_object(mem, sizeof(*extents)))
+		return NULL;
+
 	buf = dm_zalloc(STATS_FIE_BUF_LEN);
 	if (!buf) {
 		log_error("Could not allocate memory for FIEMAP buffer.");
-		return NULL;
+		goto bad;
 	}
 
 	/* initialise pointers into the ioctl buffer. */
@@ -4415,10 +4419,6 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	*count = (STATS_FIE_BUF_LEN - sizeof(*fiemap))
 		  / sizeof(struct fiemap_extent);
 
-	/* grow temporary extent table in the pool */
-	if (!dm_pool_begin_object(mem, sizeof(*extents)))
-		return NULL;
-
 	flags = FIEMAP_FLAG_SYNC;
 
 	do {


