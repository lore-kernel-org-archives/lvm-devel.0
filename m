From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 22:43:51 +0000 (UTC)
Subject: master - libdm: use 'goto_bad' if extent pool allocation fails
Message-ID: <20160708224351.E9DC36100A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=61cb58e549e5ff55095733bc3c7277c83584e5a0
Commit:        61cb58e549e5ff55095733bc3c7277c83584e5a0
Parent:        feb69966d404346208f460f2b5c45d85783cc1ce
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 22:28:50 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 22:28:50 2016 +0100

libdm: use 'goto_bad' if extent pool allocation fails

Generate a backtrace if unable to extend the extent table.
---
 libdm/libdm-stats.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index a5358bf..612f9bf 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4208,7 +4208,7 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 				tot_extents++;
 				if (!_stats_add_extent(mem, fm_ext + i,
 						       tot_extents - 1))
-					goto bad;
+					goto_bad;
 			} else {
 				expected = 0;
 				if (!tot_extents)
@@ -4216,7 +4216,7 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 				if (fm_ext[i].fe_logical == 0)
 					if (!_stats_add_extent(mem, fm_ext + i,
 							       tot_extents - 1))
-						goto bad;
+						goto_bad;
 			}
 			num += tot_extents;
 			if (fm_ext[i].fe_flags & FIEMAP_EXTENT_LAST)


