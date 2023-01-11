From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 11 Jan 2023 11:15:14 +0000 (GMT)
Subject: rhel-9.2.0 - lvextend: fix overprovisioning check for thin lvs
Message-ID: <20230111111514.5DE273858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=20c6961e37bf6f5010f9d2035dbc1ce03f9b0223
Commit:        20c6961e37bf6f5010f9d2035dbc1ce03f9b0223
Parent:        b01433cdc841133500a0ed4041b9b35838d45e87
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 15 09:57:04 2022 -0600
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 22 12:25:45 2022 +0100

lvextend: fix overprovisioning check for thin lvs

18722dfdf4d3 lvresize: restructure code
mistakenly changed the overprovisioning check from applying
to all lv_is_thin_type lvs to only lv_is_thin_pool lvs, so
it no longer applied when extending thin lvs.  The result
was missing warning messages when extending thin lvs.

(cherry picked from commit 4baef0f93f608403b6f2db445e7bf1e80f8f3ee6)
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

