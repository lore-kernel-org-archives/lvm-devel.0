From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 29 Aug 2014 11:12:43 +0000 (UTC)
Subject: master - cleanup: drop extra ()
Message-ID: <20140829111243.6157F60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa1a0d170ad7193e9d0c6fe828a5c5df24806a54
Commit:        fa1a0d170ad7193e9d0c6fe828a5c5df24806a54
Parent:        2a0ec5d3968414bff251f1750e911c9dd120ca69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 29 11:58:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 29 13:11:35 2014 +0200

cleanup: drop extra ()

Pure  '==' test doesn't need extra ().
---
 libdm/libdm-report.c |    2 +-
 tools/lvchange.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6e7167f..8c27c5b 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2122,7 +2122,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	}
 
 	/* Store information whether [] or {} was used. */
-	if ((end_op_flag_expected == SEL_LIST_LE))
+	if (end_op_flag_expected == SEL_LIST_LE)
 		ssl->type |= SEL_LIST_LS;
 	else
 		ssl->type |= SEL_LIST_SUBSET_LS;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0981f2c..31c397b 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -794,7 +794,7 @@ static int lvchange_writemostly(struct logical_volume *lv)
 				 * We don't bother checking the metadata area,
 				 * since writemostly only affects the data areas.
 				 */
-				if ((seg_type(raid_seg, s) == AREA_UNASSIGNED))
+				if (seg_type(raid_seg, s) == AREA_UNASSIGNED)
 					continue;
 
 				if (lv_is_on_pv(seg_lv(raid_seg, s), pvl->pv)) {


