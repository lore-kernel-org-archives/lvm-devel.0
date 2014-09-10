From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 10 Sep 2014 22:02:14 +0000 (UTC)
Subject: master - lv_rename: actual fix for snapshot
Message-ID: <20140910220214.CA19260515@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a86d9a3b305be466d221f2a5e210bc1cad8fe842
Commit:        a86d9a3b305be466d221f2a5e210bc1cad8fe842
Parent:        c710f02e0181cc2db5455f0c98033247a70ecc30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 9 20:15:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 9 20:15:51 2014 +0200

lv_rename: actual fix for snapshot

By my rebasing mistake it's been eliminated from previous patch set.
---
 lib/metadata/lv_manip.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cc7b6da..8c1bd83 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3966,6 +3966,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		log_error("Failed to allocate space for new name.");
 		return 0;
 	}
+
 	/* rename sub LVs */
 	if (!for_each_sub_lv(lv, _rename_cb, (void *) &lv_names))
 		return_0;
@@ -3973,6 +3974,9 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	/* rename main LV */
 	lv->name = lv_names.new;
 
+	if (lv_is_cow(lv))
+		lv = origin_from_cow(lv);
+
 	if (update_mda && !lv_update_and_reload(lv))
 		return_0;
 


