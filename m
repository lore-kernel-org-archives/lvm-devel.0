From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 24 Jun 2020 12:04:09 +0000 (GMT)
Subject: master - lv{resize, extend, reduce}: also check for 2-legged raid4
Message-ID: <20200624120409.B70283898515@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04bba5ea421b02275197bfb16b4d1bbf8879b240
Commit:        04bba5ea421b02275197bfb16b4d1bbf8879b240
Parent:        2cf0f90780bed64cb4062eb6dfa714ed03eecfb7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jun 24 14:02:29 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jun 24 14:02:31 2020 +0200

lv{resize,extend,reduce}: also check for 2-legged raid4

Users can also convert 2-legged raid1 to raid4 thus causing 'Bus error'
on resize requests.

Related: https://bugzilla.redhat.com/show_bug.cgi?id=1784351
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 142435bbb..1642b90a0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5090,7 +5090,7 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (seg && seg_is_any_raid5(seg) && seg->area_count < 3) {
+	if (seg && (seg_is_raid4(seg) || seg_is_any_raid5(seg)) && seg->area_count < 3) {
 		log_error("Cannot resize %s LV %s. Convert to more stripes first.",
 			  lvseg_name(seg), display_lvname(lv));
 		return 0;


