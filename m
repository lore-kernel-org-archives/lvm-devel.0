From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 11:31:40 +0000 (UTC)
Subject: master - libdm: fix group resource leak in dm_stats_delete_region()
Message-ID: <20160708113140.C4D1760F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebc7fc67c88790a475eaaa3f6d650ca81012ed16
Commit:        ebc7fc67c88790a475eaaa3f6d650ca81012ed16
Parent:        005adb0a0a5bfbe3ffbf94a41b1619001d8576b3
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 13:45:06 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 12:30:09 2016 +0100

libdm: fix group resource leak in dm_stats_delete_region()

The function _stats_remove_region_id_from_group() incorecctly set
the group_id to DM_STATS_GROUP_NOT_PRESENT _before_ the call to
_stats_group_destroy(). This will cause the destroy function to
return immediately without doing anything:

 339 static void _stats_group_destroy(struct dm_stats_group *group)
 340 {
 341         if (!_stats_group_present(group))
 342                 return;

Invalidating the ID in _stats_region_region_id_from_group() is
redundant anyway; it is rightly done as the last operation in
_stats_group_destroy (and it is not possible for anything to see
the old value between the two calls).

Remove the change to group_id to ensure that the alias and bitset
resources are correctly freed.
---
 libdm/libdm-stats.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 9b55813..46495c3 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1980,7 +1980,6 @@ static int _stats_remove_region_id_from_group(struct dm_stats *dms,
 
 	/* removing group leader? */
 	if (region_id == group_id) {
-		dms->groups[group_id].group_id = DM_STATS_GROUP_NOT_PRESENT;
 		_stats_clear_group_regions(dms, group_id);
 		_stats_group_destroy(&dms->groups[group_id]);
 	}


