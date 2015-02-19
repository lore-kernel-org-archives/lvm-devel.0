From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Feb 2015 13:44:33 +0000 (UTC)
Subject: master - cleanup: simplify error path code
Message-ID: <20150219134433.C447F60057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a18d789684e0fd1864e419b4ee8ba97c3a37030f
Commit:        a18d789684e0fd1864e419b4ee8ba97c3a37030f
Parent:        4c184e9d6b4aa74b5fbed0fb8710dc38b38545f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 19 14:06:17 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 19 14:44:04 2015 +0100

cleanup: simplify error path code

Mempool needs to free only with first alllocated element,
everything allocated afterwards is released as well.
---
 lib/metadata/lv_manip.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 088daaf..a77142c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -460,7 +460,7 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 
 	if (!(*layout = str_list_create(mem))) {
 		log_error("LV layout list allocation failed");
-		goto bad;
+		return 0;
 	}
 
 	if (!(*role = str_list_create(mem))) {
@@ -549,10 +549,8 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 
 	return 1;
 bad:
-	if (*role)
-		dm_pool_free(mem, *role);
-	if (*layout)
-		dm_pool_free(mem, *layout);
+	dm_pool_free(mem, *layout);
+
 	return 0;
 }
 


