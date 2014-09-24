From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:21 +0000 (UTC)
Subject: master - cleanup: drop uneeded backup call
Message-ID: <20140924085721.66D17613A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f809fa5a7865bb59d9a2616629523429dd7ec629
Commit:        f809fa5a7865bb59d9a2616629523429dd7ec629
Parent:        ec4ffeb51ca15d5bd79acf77dfe38630328f1db0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 14:11:12 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

cleanup: drop uneeded backup call

lv_update_and_reload already handle backup.
---
 tools/lvconvert.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9681f3a..cc874c5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2572,8 +2572,6 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 				display_lvname(torigin_lv),
 				display_lvname(lv));
 
-	backup(vg);
-
 	return 1;
 
 deactivate_and_revert_new_lv:


