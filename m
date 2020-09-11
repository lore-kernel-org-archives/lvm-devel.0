From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Fri, 11 Sep 2020 17:42:16 +0800
Subject: [PATCH 3/4] lvconvert: _lvconvert_splitsnapshot check if lv is snapshot type
In-Reply-To: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
References: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
Message-ID: <f9fb4cf0-39e0-fe0d-803a-1105e358a7f5@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

cow may not be a snapshot type, the return value of origin_from_cow(cow) may be NULL

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
Signed-off-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/lvconvert.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0adc61e36..f6a5572c7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1825,6 +1825,9 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	struct volume_group *vg = cow->vg;
 	const char *cow_name = display_lvname(cow);

+	if (!lv_is_snapshot(cow))
+		return 0;
+
 	if (lv_is_virtual_origin(origin_from_cow(cow))) {
 		log_error("Unable to split off snapshot %s with virtual origin.", cow_name);
 		return 0;
-- 


