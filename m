From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 10 Mar 2017 16:46:41 -0500
Subject: master - report: fix lv_size with reshape space allocated
Message-ID: <201703102146.v2ALkeMm030788@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09ad36fb9b3bc7cda7aa946c39a387ad69317be7
Commit:        09ad36fb9b3bc7cda7aa946c39a387ad69317be7
Parent:        c8671f6f798ec2516887a0d4abdebefcad0ce0ee
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 10 22:44:32 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 10 22:46:20 2017 +0100

report: fix lv_size with reshape space allocated

Commit f4b30b0daef3 was about displaying visible LV size
when reshape space is allocated.  Take parity devices
into account when displaying the user visible LV size.
---
 lib/report/report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index afd922e..fcb9e33 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2321,7 +2321,7 @@ static int _lv_size_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint64_t size = lv->le_count;
 
 	if (seg && !lv_is_raid_image(lv))
-		size -= seg->reshape_len * (seg->area_count > 2 ? seg->area_count : 1);
+		size -= seg->reshape_len * (seg->area_count > 2 ? (seg->area_count - seg->segtype->parity_devs) : 1);
 
 	size *= lv->vg->extent_size;
 


