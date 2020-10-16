From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:21 +0000 (GMT)
Subject: stable-2.02 - lvconvert: check if LV has cow type
Message-ID: <20201016191121.4B6F9396EC8D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a83e1536704c028b96b91b74fcf8e5809cdf0014
Commit:        a83e1536704c028b96b91b74fcf8e5809cdf0014
Parent:        d7131ab4399b3dde28a97e6423622805c6b3bd00
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 12:08:15 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

lvconvert: check if LV has cow type

Cow may not be a COW type, the return value of origin_from_cow(cow) may be NULL.

Reported-by: Wu Guanghao <wuguanghao3@huawei.com>
Reported-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/lvconvert.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4da9655e8..4dc2eed59 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1815,6 +1815,11 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
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


