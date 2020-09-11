From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:47 +0000 (GMT)
Subject: master - lvconvert_poll: ensure LV has snapshot type
Message-ID: <20200911195347.5409B386F024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=223b75ee91cdd820d384ce281780c36a9e055b76
Commit:        223b75ee91cdd820d384ce281780c36a9e055b76
Parent:        d71199920fe3a43582c0f2ca629ad502cfb189b5
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Fri Sep 11 17:41:01 2020 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:47:34 2020 +0200

lvconvert_poll: ensure LV has snapshot type

LV may not be a snapshot type, the return value of find_snapshot(lv) may be NULL.
Here, we will call stack if LV is not a snapshot type.

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
Signed-off-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/lvconvert_poll.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index b9ec316e1..0eae74616 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -176,7 +176,7 @@ progress_t poll_thin_merge_progress(struct cmd_context *cmd,
 {
 	uint32_t device_id;
 
-	if (!lv_thin_device_id(lv, &device_id)) {
+	if (!lv_thin_device_id(lv, &device_id) && !lv_is_snapshot(lv)) {
 		stack;
 		return PROGRESS_CHECK_FAILED;
 	}


