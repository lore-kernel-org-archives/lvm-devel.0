From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 20:31:52 +0000 (UTC)
Subject: master - libdm: fix segfault with invalid group descriptor
Message-ID: <20161213203152.C5FEE60659@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99b6d82e2dac7ef097fa940c64456620930d7758
Commit:        99b6d82e2dac7ef097fa940c64456620930d7758
Parent:        138e4336fd8422623df7daa362b98a4899f5fbec
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Dec 13 13:56:10 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 14:37:41 2016 +0000

libdm: fix segfault with invalid group descriptor

If a region has a a DMS_GROUP tag in aux_data where the first
region_id in the bitmap is not the same as the containing region,
dmstats will segfault:

  # '2' is never a valid group bitset list for region_id == 0
  # dmsetup message vg_hex/root 0 "@stats_set_aux 0 DMS_GROUP=img:2#"

  # dmsetup message vg_hex/root 0 "@stats_list"
  0: 45383680+16384 16384 dmstats DMS_GROUP=img:2#
  1: 46071808+32768 32768 dmstats -
  2: 47382528+16384 16384 dmstats -

  # dmstats list
  Segmentation fault (core dumped)

The crash will occur in some arbitrary dm_stats_get_* property
method - this happens while processing the 1st region_id in the
bitset, because the region is marked as grouped, but there is
no group bitmap present at dms->groups[2]->regions.

Fix this by detecting a mismatch between the expected region_id
and dm_bit_get_first() for the parsed bitset during
_parse_aux_data_group().
---
 libdm/libdm-stats.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 8c0428e..5833ac6 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -708,8 +708,14 @@ static int _parse_aux_data_group(struct dm_stats *dms,
 	}
 
 	group->group_id = dm_bit_get_first(regions);
-	group->regions = regions;
+	if (group->group_id != region->region_id) {
+		log_error("Found invalid group descriptor in region " FMTu64
+			  " aux_data.", region->region_id);
+		group->group_id = DM_STATS_GROUP_NOT_PRESENT;
+		goto bad;
+	}
 
+	group->regions = regions;
 	group->alias = NULL;
 	if (strlen(alias)) {
 		group->alias = dm_strdup(alias);


