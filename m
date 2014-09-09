From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  9 Sep 2014 17:23:31 +0000 (UTC)
Subject: master - lv_manip: remove vg_revert
Message-ID: <20140909172331.C29FD60FD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aee8611af5992db2dd19a4235849f1953b560364
Commit:        aee8611af5992db2dd19a4235849f1953b560364
Parent:        413fc9d3e699206ec493a70c6baf98bc87b83a9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 8 22:39:58 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 9 19:15:26 2014 +0200

lv_manip: remove vg_revert

vg_commit is supposed to have implicit revert handling.
(however as of now it needs fixes).
---
 lib/metadata/lv_manip.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7374484..cec9f84 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6096,7 +6096,6 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 
 		if (!vg_commit(lv_where->vg)) {
 			log_error("Failed to commit intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
-			vg_revert(lv_where->vg);
 			return NULL;
 		}
 


