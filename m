From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Aug 2019 14:28:53 -0400
Subject: master - pvscan cache: use lvmcache_label_scan
Message-ID: <201908161828.x7GISrq6006536@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83261b79b578f213127af6350c555ec347b7211a
Commit:        83261b79b578f213127af6350c555ec347b7211a
Parent:        e01fddc5789b10d1bd15e8aee8985f14e81d3087
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 15:07:59 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 16 13:26:12 2019 -0500

pvscan cache: use lvmcache_label_scan

instead of the lower level label_scan.  The lvmcache wrapper
around label_scan checks for and eliminates more duplicate devs
and md components.
---
 tools/pvscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 168d509..ac41500 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -759,7 +759,7 @@ static void _online_pvscan_all_devs(struct cmd_context *cmd,
 
 	dm_list_init(&all_vgs);
 
-	label_scan(cmd);
+	lvmcache_label_scan(cmd);
 
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed");


