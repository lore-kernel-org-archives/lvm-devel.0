From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Nov 2022 11:41:39 +0000 (GMT)
Subject: main - lvcreate: fix error path return values
Message-ID: <20221108114139.9728938582AA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9f35e07db41f3dd6bea2c91a8bc1bff93a4d406
Commit:        b9f35e07db41f3dd6bea2c91a8bc1bff93a4d406
Parent:        0fed9b097120648301faa586970a47b8b4d629ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 8 12:39:25 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 8 12:39:25 2022 +0100

lvcreate: fix error path return values

Return failing error code for return path, as 'return 0' in this
case was returning success.
---
 tools/lvcreate.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 670c52913..3c89fd2c1 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1750,21 +1750,21 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 		goto_out;
 
 	if (seg_is_vdo(lp) && !_check_vdo_parameters(vg, lp, lcp))
-		return_0;
+		goto_out;
 
 	if (!_check_pool_parameters(cmd, vg, lp, lcp))
 		goto_out;
 
 	/* All types are checked */
 	if (!_check_zero_parameters(cmd, lp))
-		return_0;
+		goto_out;
 
 	if (!_update_extents_params(vg, lp, lcp))
 		goto_out;
 
 	if (seg_is_vdo(lp) && !check_vdo_constrains(cmd, (uint64_t)lp->extents * vg->extent_size,
 						    lcp->virtual_size, &lp->vdo_params))
-		return_0;
+		goto_out;
 
 	if (seg_is_thin(lp) && !_validate_internal_thin_processing(lp))
 		goto_out;

