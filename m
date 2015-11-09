From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:39 +0000 (UTC)
Subject: master - report: add extra pointer check
Message-ID: <20151109092839.4AF4460FA0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f8f8fcb52d1d1f2a46468aa6bb4a8da11804c5b
Commit:        4f8f8fcb52d1d1f2a46468aa6bb4a8da11804c5b
Parent:        856e11e11c3b3ba4da3cbbd21982d34daa51aaa0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 17:19:21 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:20 2015 +0100

report: add extra pointer check

Coverity was seeing possible trouble with NULL pointer dereference.
So ensure it may never happen.
---
 lib/report/report.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 911c96e..91522b1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -960,13 +960,13 @@ static int _translate_time_items(struct dm_report *rh, struct time_info *info,
 					t += (multiplier * SECS_PER_HOUR);
 					break;
 				case TIME_UNIT_AM:
-					if (ti_p->prop->id == TIME_NUM_MULTIPLIER)
+					if (ti_p && ti_p->prop->id == TIME_NUM_MULTIPLIER)
 						tm.tm_hour = multiplier;
 					break;
 				case TIME_UNIT_PM:
-					if (_is_time_unit(ti_p->prop->id))
+					if (ti_p && _is_time_unit(ti_p->prop->id))
 						t -= 12 * SECS_PER_HOUR;
-					else if (ti_p->prop->id == TIME_NUM_MULTIPLIER)
+					else if (ti_p && ti_p->prop->id == TIME_NUM_MULTIPLIER)
 						tm.tm_hour = multiplier + 12;
 					break;
 				case TIME_UNIT_DAY:


