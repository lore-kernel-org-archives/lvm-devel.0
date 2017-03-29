From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:41 -0400
Subject: master - libdm: abort filemap update if pool allocation fails (coverity)
Message-ID: <201703292016.v2TKGfNm000850@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f86c1f5d0a38afc9d174e59af4bab83127e4b2b8
Commit:        f86c1f5d0a38afc9d174e59af4bab83127e4b2b8
Parent:        bc5d67884fd489682c0267002474e9089e368fe2
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:39:31 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:38 2017 +0100

libdm: abort filemap update if pool allocation fails (coverity)

---
 libdm/libdm-stats.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 5041d61..94696fb 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4540,8 +4540,9 @@ static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
 			ext.id = i;
 			nr_kept++;
 
-			dm_pool_grow_object(mem, &ext,
-					    sizeof(ext));
+			if (!dm_pool_grow_object(mem, &ext, sizeof(ext)))
+				goto out;
+
 			log_very_verbose("Kept region " FMTu64, i);
 		} else {
 


