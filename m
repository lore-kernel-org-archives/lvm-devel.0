From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:24:49 -0400
Subject: master - reporting: validate time parsing with strtol
Message-ID: <201708251224.v7PCOn03005079@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26d97f179fabe0669dc10e7e16398803c323ca93
Commit:        26d97f179fabe0669dc10e7e16398803c323ca93
Parent:        d79d9193298b04246c18dcacd8b372518eb10ffc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 11:58:33 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:20:59 2017 +0200

reporting: validate time parsing with strtol

Check for out-of-range numbers being result of strtol parsing.
---
 lib/report/report.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 89110f0..c32df71 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -898,7 +898,12 @@ static int _translate_time_items(struct dm_report *rh, struct time_info *info,
 		id = ti->prop->id;
 
 		if (_is_time_num(id)) {
+			errno = 0;
 			num = strtol(ti->s, &end, 10);
+			if (errno) {
+				log_error("_translate_time_items: invalid time.");
+				return 0;
+			}
 			switch (id) {
 				case TIME_NUM_MULTIPLIER_NEGATIVE:
 					multiplier = -num;


