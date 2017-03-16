From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Mar 2017 20:02:35 -0400
Subject: master - thin: remove unneeed test for NULL
Message-ID: <201703160002.v2G02ZHX017642@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a139993b40c4497536a2a0b6d826c73213b332d
Commit:        2a139993b40c4497536a2a0b6d826c73213b332d
Parent:        0dcb928d1e7fb75d6481923effe509237de119de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 16 00:34:31 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 01:02:10 2017 +0100

thin: remove unneeed test for NULL

In this API NULL is not valid parameter so do not check for it.
---
 lib/metadata/thin_manip.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index d1259b4..71f9cc0 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -649,8 +649,7 @@ int update_thin_pool_params(struct cmd_context *cmd,
 			return_0;
 	}
 
-	if (zero_new_blocks &&
-	    (*zero_new_blocks == THIN_ZERO_UNSELECTED) &&
+	if ((*zero_new_blocks == THIN_ZERO_UNSELECTED) &&
 	    find_config_tree_node(cmd, allocation_thin_pool_zero_CFG, profile))
 		*zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile)
 			? THIN_ZERO_YES : THIN_ZERO_NO;


