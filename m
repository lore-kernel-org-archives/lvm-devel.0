From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:41:54 +0000 (UTC)
Subject: master - libdm: ensure first extent is always counted
Message-ID: <20161213214154.1316860CDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4401fe351f63679ae8f4bab448a9283fb631a4a
Commit:        f4401fe351f63679ae8f4bab448a9283fb631a4a
Parent:        fce7449d7311b49839f339b714c48e953e9a837a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Dec 13 21:36:11 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 21:41:31 2016 +0000

libdm: ensure first extent is always counted

If FIEMAP returns a single extent after the first call, no extent
boundary is detected and the first extent is not counted by the
normal mechanism.

In this case, increment nr_extents at the same time the extent is
added to the region table, before returning.
---
 libdm/libdm-stats.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 02a30dc..8d202d2 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4286,8 +4286,10 @@ static uint64_t _stats_map_extents(struct dm_pool *mem,
 	 * If the file only has a single extent, no boundary is ever
 	 * detected to trigger addition of the first extent.
 	 */
-	if (fm_ext[i - 1].fe_logical == 0)
+	if (fm_ext[i - 1].fe_logical == 0) {
 		_stats_add_extent(mem, fm_pending, nr_extents);
+		nr_extents++;
+	}
 
 	fiemap->fm_start = (fm_ext[i - 1].fe_logical +
 			    fm_ext[i - 1].fe_length);


