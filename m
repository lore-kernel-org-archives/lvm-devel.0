From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Fri, 11 Sep 2020 17:41:01 +0800
Subject: [PATCH 2/4] lvconvert_poll: check whether lv is a snapshot type in poll_thin_merge_progress
In-Reply-To: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
References: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
Message-ID: <4f0c1766-448a-8821-73f8-235665e73661@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lv may not be a snapshot type, the return value of find_snapshot(lv) may be NULL.
Here, we will call stack if lv is not a snapshot type.

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
Signed-off-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/lvconvert_poll.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index b9ec316e1..d0831cfd8 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -176,7 +176,7 @@ progress_t poll_thin_merge_progress(struct cmd_context *cmd,
 {
 	uint32_t device_id;

-	if (!lv_thin_device_id(lv, &device_id)) {
+	if (!lv_thin_device_id(lv, &device_id) || !lv_is_snapshot(lv)) {
 		stack;
 		return PROGRESS_CHECK_FAILED;
 	}
-- 


