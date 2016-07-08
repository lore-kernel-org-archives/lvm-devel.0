From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 22:43:49 +0000 (UTC)
Subject: master - libdm: use macro for boundary test in _stats_get_extents_for_file()
Message-ID: <20160708224349.D480B6100A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=feb69966d404346208f460f2b5c45d85783cc1ce
Commit:        feb69966d404346208f460f2b5c45d85783cc1ce
Parent:        74565e41fc55a99c2c7b750225fd3a616ea84648
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 22:21:14 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 22:21:14 2016 +0100

libdm: use macro for boundary test in _stats_get_extents_for_file()

---
 libdm/libdm-stats.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index bf9b7e3..a5358bf 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4137,6 +4137,12 @@ static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
 
 }
 
+/* test for the boundary of an extent */
+#define ext_boundary(ext, exp, exp_dense)	\
+(((ext).fe_logical != 0) &&			\
+((ext).fe_physical != (exp)) &&			\
+((ext).fe_physical != (exp_dense)))
+
 /*
  * Read the extents of an open file descriptor into a table of struct _extent.
  *
@@ -4198,9 +4204,7 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 					 fm_last.fe_length;
 			expected = fm_last.fe_physical +
 				   fm_ext[i].fe_logical - fm_last.fe_logical;
-			if ((fm_ext[i].fe_logical != 0)
-			    && (fm_ext[i].fe_physical != expected)
-			    && (fm_ext[i].fe_physical != expected_dense)) {
+			if (ext_boundary(fm_ext[i], expected, expected_dense)) {
 				tot_extents++;
 				if (!_stats_add_extent(mem, fm_ext + i,
 						       tot_extents - 1))


