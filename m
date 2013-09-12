From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Sep 2013 08:42:17 +0000 (UTC)
Subject: master - cleanup: hide gcc warning
Message-ID: <20130912084217.6DA4960B3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8ea27ac97ef94837f6ee3fce86fd65dcb294d65
Commit:        b8ea27ac97ef94837f6ee3fce86fd65dcb294d65
Parent:        82228acfc95fa4dbe9acca2d3bfc5a89087fd5e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 9 13:06:05 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 11 23:40:45 2013 +0200

cleanup: hide gcc warning

Older gcc is giving misleading warning:

metadata/lv_manip.c:4018: warning: ???seg??? may be used uninitialized in
this function

But warning free compilation is better.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d12b34e..a145c41 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4016,7 +4016,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 {
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *lock_lv = NULL;
-	struct lv_segment *seg;
+	struct lv_segment *seg = NULL;
 	int status;
 	alloc_policy_t alloc;
 


