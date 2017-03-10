From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 10 Mar 2017 14:39:13 -0500
Subject: master - raid: fix compile time warning
Message-ID: <201703101939.v2AJdDwi012165@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d3e870946fecdc6deefbef41430ec561eed183a
Commit:        5d3e870946fecdc6deefbef41430ec561eed183a
Parent:        53f5cf0af000f9c80b320e57eb44ba76d2ccf7a2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 10 20:37:42 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 10 20:38:16 2017 +0100

raid: fix compile time warning

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9954133..e6d269e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -494,7 +494,7 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 	int flags_reset = 0, r = 0;
 	va_list ap;
 	fn_on_lv_t fn_pre_on_lv = NULL, fn_post_on_lv;
-	void *fn_pre_data, *fn_post_data;
+	void *fn_pre_data, *fn_post_data = NULL;
 	struct dm_list *removal_lvs;
 
 	va_start(ap, origin_only);


