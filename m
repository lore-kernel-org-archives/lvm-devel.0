From: David Teigland <teigland@sourceware.org>
Date: Wed,  9 Sep 2020 15:25:32 +0000 (GMT)
Subject: master - integrity: fix segfault reporting integrity for other lvs
Message-ID: <20200909152532.50617383F85C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f54129c4ea4cc88571b75b7d093107985913315
Commit:        1f54129c4ea4cc88571b75b7d093107985913315
Parent:        0210c7076d0db2fc835ed11a86a901c725096e6f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 9 10:22:07 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 9 10:22:07 2020 -0500

integrity: fix segfault reporting integrity for other lvs

---
 lib/report/report.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/report/report.c b/lib/report/report.c
index cd7971562..73a150a7e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3286,6 +3286,8 @@ static int _raidintegritymode_disp(struct dm_report *rh __attribute__((unused)),
 		lv_get_raid_integrity_settings(lv, &settings);
 	else if (lv_is_integrity(lv))
 		settings = &first_seg(lv)->integrity_settings;
+	else
+		goto out;
 
 	if (settings->mode[0]) {
 		if (settings->mode[0] == 'B')
@@ -3301,6 +3303,7 @@ static int _raidintegritymode_disp(struct dm_report *rh __attribute__((unused)),
 			return _field_set_value(field, repstr, NULL);
 		}
 	}
+out:
 	return _field_set_value(field, "", NULL);
 }
 


