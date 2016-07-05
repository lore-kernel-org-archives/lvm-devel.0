From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:54 +0000 (UTC)
Subject: master - dmstats: report a list of members as a group's region_id
Message-ID: <20160705185454.DF9B5603FF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2bf3c6ee8ae6e03bd1351e59f1a097c92205dec
Commit:        a2bf3c6ee8ae6e03bd1351e59f1a097c92205dec
Parent:        ca0a4cececf372a5d420e9402fec86d5cd013bf5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Jun 19 21:01:50 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: report a list of members as a group's region_id

Instead of '-' print the member list in range notation (as stored
in aux_data).
---
 tools/dmsetup.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d1f93fd..ae04c9d 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3264,11 +3264,16 @@ static int _dm_stats_region_id_disp(struct dm_report *rh,
 				    void *private __attribute__((unused)))
 {
 	const struct dm_stats *dms = (const struct dm_stats *) data;
-	uint64_t region_id = dm_stats_get_current_region(dms);
+	uint64_t group_id, region_id = dm_stats_get_current_region(dms);
+	char *group_buf = NULL, *repstr;
 
 	if (dm_stats_current_object_type(dms) == DM_STATS_OBJECT_TYPE_GROUP) {
-		/* FIXME: output group region list and use group_id as sortval. */
-		dm_report_field_set_value(field, "-", &region_id);
+		group_id = dm_stats_get_group_id(dms, dm_stats_get_current_region(dms));
+		if (!dm_stats_get_group_descriptor(dms, group_id, &group_buf))
+			return 0;
+		/* group_buf will disappear with the current handle */
+		repstr = dm_pool_strdup(mem, group_buf);
+		dm_report_field_set_value(field, repstr, &group_id);
 		return 1;
 	}
 


