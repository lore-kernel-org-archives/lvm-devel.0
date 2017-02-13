From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:14:53 +0000 (UTC)
Subject: master - cleanup: use fall through
Message-ID: <20170213091453.D4EEE60E73@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6301aa977df675918f25f6ace11628fa846392c
Commit:        b6301aa977df675918f25f6ace11628fa846392c
Parent:        a39c828c01f747696a6e042df48da62ec0e1ba75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 18:17:07 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 10:06:18 2017 +0100

cleanup: use fall through

gcc gets 'selective' on having commented fall through case.
---
 lib/metadata/metadata.c |    2 +-
 libdm/libdm-report.c    |    5 +++++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1289fec..0731108 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1256,7 +1256,7 @@ uint32_t extents_from_percent_size(struct volume_group *vg, const struct dm_list
 			}
 			break;
 		}
-		/* Fall back to use all PVs in VG like %FREE */
+		/* fall through to use all PVs in VG like %FREE */
 	case PERCENT_FREE:
 		if (!(extents = vg->free_count)) {
 			log_error("No free extents in Volume group %s.", vg->name);
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 93b8774..f9e261d 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3062,26 +3062,31 @@ static void _get_final_time(time_range_t range, struct tm *tm,
 				tm_up.tm_sec += 1;
 				break;
 			}
+			/* fall through */
 		case RANGE_MINUTE:
 			if (tm_up.tm_min < 59) {
 				tm_up.tm_min += 1;
 				break;
 			}
+			/* fall through */
 		case RANGE_HOUR:
 			if (tm_up.tm_hour < 23) {
 				tm_up.tm_hour += 1;
 				break;
 			}
+			/* fall through */
 		case RANGE_DAY:
 			if (tm_up.tm_mday < _get_days_in_month(tm_up.tm_mon, tm_up.tm_year)) {
 				tm_up.tm_mday += 1;
 				break;
 			}
+			/* fall through */
 		case RANGE_MONTH:
 			if (tm_up.tm_mon < 11) {
 				tm_up.tm_mon += 1;
 				break;
 			}
+			/* fall through */
 		case RANGE_YEAR:
 			tm_up.tm_year += 1;
 			break;


