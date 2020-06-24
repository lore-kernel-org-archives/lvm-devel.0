From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 24 Jun 2020 12:04:51 +0000 (GMT)
Subject: stable-2.02 - lv{resize, extend, reduce}: also check for 2-legged raid4
Message-ID: <20200624120451.367CF3870872@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7e2288ff4ac34d825dd13dd45b0418723a7da84
Commit:        e7e2288ff4ac34d825dd13dd45b0418723a7da84
Parent:        d17780c6b85a0f136e0ed395d5722d82bd8c7464
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jun 24 14:02:29 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jun 24 14:04:36 2020 +0200

lv{resize,extend,reduce}: also check for 2-legged raid4

Users can also convert 2-legged raid1 to raid4 thus causing 'Bus error'
on resize requests.

Related: https://bugzilla.redhat.com/show_bug.cgi?id=1784351
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d35eb5e0a..0b1fdce27 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4797,7 +4797,7 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (seg && seg_is_any_raid5(seg) && seg->area_count < 3) {
+	if (seg && (seg_is_raid4(seg) || seg_is_any_raid5(seg)) && seg->area_count < 3) {
 		log_error("Cannot resize %s LV %s. Convert to more stripes first.",
 			  lvseg_name(seg), display_lvname(lv));
 		return 0;


