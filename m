From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:13 +0000 (UTC)
Subject: master - cleanup: release all memory in error path
Message-ID: <20130923101613.5268E60D85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=85b9c12e92873a87b7c02bac20287beeea82ef2a
Commit:        85b9c12e92873a87b7c02bac20287beeea82ef2a
Parent:        30432bd6048ce9c52eefeba9e99d1b0805c6c59b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 19 22:23:43 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 11:35:15 2013 +0200

cleanup: release all memory in error path

Just ensure no memory will stay in pool even in error path.
---
 lib/activate/dev_manager.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 11be421..b8233bf 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -500,13 +500,15 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 
 	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer))) {
 		log_error("dlid build failed for %s", name);
-		return 0;
+		r = 0;
+		goto out;
 	}
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
 	r = _info(dlid, with_open_count, with_read_ahead, info, read_ahead);
-
+out:
 	dm_pool_free(mem, name);
+
 	return r;
 }
 


