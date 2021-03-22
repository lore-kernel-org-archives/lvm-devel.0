From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:11 +0000 (GMT)
Subject: dev-next - thin: ignore parallel merge while polling
Message-ID: <20210322153911.AAD163854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a60c8748eac2e6f047532b6d106492d120860608
Commit:        a60c8748eac2e6f047532b6d106492d120860608
Parent:        8cbe4a171e093aa7de9e16115b13ee3852545d07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 11:17:32 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

thin: ignore parallel merge while polling

If the thin volume has no merging snapshot,
(being already merged) there is nothing to check.
---
 tools/lvconvert_poll.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index b64cffe21..50d47164f 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -179,7 +179,10 @@ progress_t poll_thin_merge_progress(struct cmd_context *cmd,
 {
 	uint32_t device_id = 0;
 
-	if (!lv_thin_device_id(lv, &device_id) || !lv->snapshot) {
+	if (!lv->snapshot)
+		return PROGRESS_FINISHED_ALL; /* Already merged by someone else */
+
+	if (!lv_thin_device_id(lv, &device_id)) {
 		stack;
 		return PROGRESS_CHECK_FAILED;
 	}


