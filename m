From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:27 +0000 (GMT)
Subject: main - thin: correct ptr test for thin snapshot merging
Message-ID: <20210310003627.583B73858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=413a114cdbb1fa0c198fb9a3f71d47dcb3d5e28d
Commit:        413a114cdbb1fa0c198fb9a3f71d47dcb3d5e28d
Parent:        b2616cd45670866b4f5b46675fe3f1563eea3415
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 16:23:08 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:09:14 2021 +0100

thin: correct ptr test for thin snapshot merging

The correct test needs to actually check  'lv->snapshot' is not NULL,
so the 'find_snapshot()' can work.

Test lv_is_snapshot was actually irrelavant for this case.

Also initialize device_id.
---
 tools/lvconvert_poll.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 0eae74616..5adb14506 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -174,9 +174,9 @@ progress_t poll_thin_merge_progress(struct cmd_context *cmd,
 				    const char *name __attribute__((unused)),
 				    struct daemon_parms *parms)
 {
-	uint32_t device_id;
+	uint32_t device_id = 0;
 
-	if (!lv_thin_device_id(lv, &device_id) && !lv_is_snapshot(lv)) {
+	if (!lv_thin_device_id(lv, &device_id) || !lv->snapshot) {
 		stack;
 		return PROGRESS_CHECK_FAILED;
 	}


