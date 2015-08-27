From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 27 Aug 2015 15:28:58 +0000 (UTC)
Subject: master - lvmlockd: fix function def for non-lvmlockd build
Message-ID: <20150827152858.74BE6603F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd238f3c0eb0ec158ac402c224f8dc5641bc1d8f
Commit:        fd238f3c0eb0ec158ac402c224f8dc5641bc1d8f
Parent:        58713d34dd71873ab97378e96d7ab0b8e9bda8ef
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 26 16:05:20 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 27 10:27:24 2015 -0500

lvmlockd: fix function def for non-lvmlockd build

---
 lib/locking/lvmlockd.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index ec36ff8..4bec782 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -129,7 +129,7 @@ static inline int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg
 	return 1;
 }
 
-static inline int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg)
+static inline int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg, int changing)
 {
 	return 1;
 }


