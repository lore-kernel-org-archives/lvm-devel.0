From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:48 +0000 (GMT)
Subject: master - lvconvert: check if LV has snapshot type
Message-ID: <20200911195348.73DEC386F027@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7db124774a2b79105e7c9c6b42df88219fc070ca
Commit:        7db124774a2b79105e7c9c6b42df88219fc070ca
Parent:        223b75ee91cdd820d384ce281780c36a9e055b76
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Fri Sep 11 17:42:16 2020 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:48:37 2020 +0200

lvconvert: check if LV has snapshot type

Cow may not be a snapshot type, the return value of origin_from_cow(cow) may be NULL

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
Signed-off-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/lvconvert.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d420eb52f..6ab8f6d2c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1825,6 +1825,11 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	struct volume_group *vg = cow->vg;
 	const char *cow_name = display_lvname(cow);
 
+	if (!lv_is_snapshot(cow)) {
+		log_error(INTERNAL_ERROR "Cow volume %s is not a snapshot.", cow_name);
+		return 0;
+	}
+
 	if (lv_is_virtual_origin(origin_from_cow(cow))) {
 		log_error("Unable to split off snapshot %s with virtual origin.", cow_name);
 		return 0;


