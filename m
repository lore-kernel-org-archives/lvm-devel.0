From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:45 +0000 (GMT)
Subject: master - lvconvert: check if LV has cow type
Message-ID: <20200912112445.89D2D3870907@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9cb96f146377ff59a34a40792a9d8537ec89755
Commit:        a9cb96f146377ff59a34a40792a9d8537ec89755
Parent:        463a61e62e32aa81391f40468d48d19948cd5062
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 12:08:15 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 12:55:20 2020 +0200

lvconvert: check if LV has cow type

Cow may not be a COW type, the return value of origin_from_cow(cow) may be NULL.

Reported-by: Wu Guanghao <wuguanghao3@huawei.com>
Reported-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/lvconvert.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d420eb52f..780a81567 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1825,6 +1825,11 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	struct volume_group *vg = cow->vg;
 	const char *cow_name = display_lvname(cow);
 
+	if (!lv_is_cow(cow)) {
+		log_error(INTERNAL_ERROR "Volume %s is not a COW.", cow_name);
+		return 0;
+	}
+
 	if (lv_is_virtual_origin(origin_from_cow(cow))) {
 		log_error("Unable to split off snapshot %s with virtual origin.", cow_name);
 		return 0;


