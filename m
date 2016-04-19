From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 14:40:49 +0000 (UTC)
Subject: master - toollib: remove unneeded call in process_each_pv
Message-ID: <20160419144049.36D9961C5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e41ee70accbc604e3a7daea0ab10f9405e95a531
Commit:        e41ee70accbc604e3a7daea0ab10f9405e95a531
Parent:        a6a32a7c0e6ed9ef9e61e82b2d1353a1c06a9dd3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 7 13:45:26 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 09:40:24 2016 -0500

toollib: remove unneeded call in process_each_pv

process_each_pv was doing:

1. lvmcache_seed_infos_from_lvmetad()
   sends pv_list request to lvmetad.

2. get_vgnameids()
   sends vg_list request to lvmetad.

3. _get_all_devices()
   first calls lvmcache_seed_infos_from_lvmetad(),
   which is a no-op if it's already been called.

Because get_vgnameids() does not use the information
from lvmcache_seed_infos_from_lvmetad(), it does not
need to be called prior to get_all_devices where
it is actually needed.
---
 tools/toollib.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b9db9cb..ac2a57a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3372,12 +3372,6 @@ int process_each_pv(struct cmd_context *cmd,
 		dev_cache_full_scan(cmd->full_filter);
 	}
 
-	/*
-	 * Need pvid's set on all PVs before processing so that pvid's
-	 * can be compared to find duplicates while processing.
-	 */
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
 	if (!get_vgnameids(cmd, &all_vgnameids, only_this_vgname, 1)) {
 		stack;
 		return ret;


