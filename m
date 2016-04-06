From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  6 Apr 2016 09:55:36 +0000 (UTC)
Subject: master - preload: preserve flushing state
Message-ID: <20160406095536.6CA6761010@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b2227c2c10c2f762e238fedb756850fe4ac5d5d
Commit:        5b2227c2c10c2f762e238fedb756850fe4ac5d5d
Parent:        7c1937f8df1e843d00b9d5814c756234381ca0d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 6 10:29:57 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 6 11:31:02 2016 +0200

preload: preserve flushing state

When leaving preload routine it should not altet state of flush required
when it's been already set to 1 and drop it to 0.

The API here is unclean, but current usage expects the same
variable pointer is for all preload calls and combines 'flush_required'
across all of them.
---
 lib/activate/dev_manager.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 994ba80..b3e97db 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3093,6 +3093,8 @@ int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv
 int dev_manager_preload(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int *flush_required)
 {
+	dm->flush_required = *flush_required;
+
 	if (!_tree_action(dm, lv, laopts, PRELOAD))
 		return_0;
 


