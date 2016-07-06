From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 15:32:36 +0000 (UTC)
Subject: master - libdm: check for empty aux_data in _parse_aux_data_group()
Message-ID: <20160706153236.D59C46180C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf1dfea393b5372b6fe058458c2fc25188e8181b
Commit:        bf1dfea393b5372b6fe058458c2fc25188e8181b
Parent:        c1a66d4fc6cd2224e3bf1f2cd08f4ee89b4ea920
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jul 6 16:29:06 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 16:31:30 2016 +0100

libdm: check for empty aux_data in _parse_aux_data_group()

If after extracting stats arguments and group tags nothing remains
of aux_data but '-' set the region->aux_data field to the empty
string to match behaviour for non-grouped regions.
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 12c821f..e979b34 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -692,7 +692,7 @@ static int _parse_aux_data_group(struct dm_stats *dms,
 	}
 
 	/* separate group tag from user aux_data */
-	if (strlen(end))
+	if ((strlen(end) > 1) || strncmp(end, "-", 1))
 		c = dm_strdup(end);
 	else
 		c = dm_strdup("");


