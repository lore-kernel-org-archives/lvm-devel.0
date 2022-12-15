From: David Teigland <teigland@sourceware.org>
Date: Thu, 15 Dec 2022 16:02:27 +0000 (GMT)
Subject: main - lvextend: fix overprovisioning check for thin lvs
Message-ID: <20221215160227.0C8663854098@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4baef0f93f608403b6f2db445e7bf1e80f8f3ee6
Commit:        4baef0f93f608403b6f2db445e7bf1e80f8f3ee6
Parent:        fa7fe5cbbe927d13a8b93aba24640ce5d8c11896
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 15 09:57:04 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 15 10:00:17 2022 -0600

lvextend: fix overprovisioning check for thin lvs

18722dfdf4d3 lvresize: restructure code
mistakenly changed the overprovisioning check from applying
to all lv_is_thin_type lvs to only lv_is_thin_pool lvs, so
it no longer applied when extending thin lvs.  The result
was missing warning messages when extending thin lvs.
---
 lib/metadata/lv_manip.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4cdbc19a0..f8eae0447 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7007,9 +7007,10 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_thin_pool(lv_top)) {
 		if (!update_thin_pool_lv(lv_top, 1))
 			goto_out;
-		if (is_extend)
-			thin_pool_check_overprovisioning(lv_top);
 	}
+	if (lv_is_thin_type(lv_top) && is_extend)
+		thin_pool_check_overprovisioning(lv_top);
+
 	if (lv_main && lv_is_cow_covering_origin(lv_main)) {
 		if (!monitor_dev_for_events(cmd, lv_main, 0, 0))
 			stack;

