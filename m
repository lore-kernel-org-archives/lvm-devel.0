From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:46 +0000 (UTC)
Subject: master - dmstats: fix <backtrace> in _display_info_cols()
Message-ID: <20160705183546.CDC2160FE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b6f7f00f725bc01d27796217cc53d77d5f42d31
Commit:        3b6f7f00f725bc01d27796217cc53d77d5f42d31
Parent:        42746c70262d8999d7780410553c64b769fca2ce
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 18:42:29 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:51 2016 +0100

dmstats: fix <backtrace> in _display_info_cols()

Remove a false <backtrace> in _display_info_cols(): it is not an
error if there are no regions to display.

Fixes commit e6724f03.
---
 tools/dmsetup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 3ee9ed8..ed03c2b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -884,9 +884,9 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		if (!dm_stats_list(obj.stats, _program_id))
 			goto_out;
 
-		/* No regions to report */
+		/* No regions to report is not an error */
 		if (!dm_stats_get_nr_regions(obj.stats))
-			goto_out;
+			goto out;
 	}
 
 	/* group report with no groups? */


