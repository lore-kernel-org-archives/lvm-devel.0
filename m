From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 20:32:01 +0000 (UTC)
Subject: master - libdm: fix start of file detection in _stats_map_extents()
Message-ID: <20161213203201.58C0F60659@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=930b0b4c9e4ca466d955f8729644ef26a939937c
Commit:        930b0b4c9e4ca466d955f8729644ef26a939937c
Parent:        eb6557221715b30a374be46e4a52f79cd7bbed44
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Dec 13 18:14:13 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 20:25:47 2016 +0000

libdm: fix start of file detection in _stats_map_extents()

---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index d9f0427..471bd7b 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4287,7 +4287,7 @@ static uint64_t _stats_map_extents(struct dm_pool *mem,
 	 * If the file only has a single extent, no boundary is ever
 	 * detected to trigger addition of the first extent.
 	 */
-	if (fm_ext[i].fe_logical == 0)
+	if (fm_ext[i - 1].fe_logical == 0)
 		_stats_add_extent(mem, fm_pending, nr_extents);
 
 	fiemap->fm_start = (fm_ext[i - 1].fe_logical +


