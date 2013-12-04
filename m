From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:45 +0000 (UTC)
Subject: master - thin: deactivation of merging thin snapshot
Message-ID: <20131204133146.0000760FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1200b7e7c2be18fcd2644817a5e57c6182800ee0
Commit:        1200b7e7c2be18fcd2644817a5e57c6182800ee0
Parent:        5fc3352a1563f0fc5a14d163b03a357742e3987e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 21:22:55 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:26 2013 +0100

thin: deactivation of merging thin snapshot

Before trying to deactivate merging thin snapshot
(which is invisible) check if it's not in-use.
---
 lib/activate/activate.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 80eef32..4c8c16d 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1973,7 +1973,8 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_vo
 		goto out;
 	}
 
-	if (lv_is_visible(lv) || lv_is_virtual_origin(lv)) {
+	if (lv_is_visible(lv) || lv_is_virtual_origin(lv) ||
+	    lv_is_merging_thin_snapshot(lv)) {
 		if (!lv_check_not_in_use(cmd, lv, &info))
 			goto_out;
 


