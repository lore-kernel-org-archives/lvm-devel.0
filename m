From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 26 Aug 2015 21:05:55 +0000 (UTC)
Subject: master - lvmlockd: fix function def for non-lvmlockd build
Message-ID: <20150826210555.7BBC86036F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b137e66e4af537110082c59f88b76ca4906e6e2
Commit:        0b137e66e4af537110082c59f88b76ca4906e6e2
Parent:        45222d29ac43b7354b275e9de61972eea4637a3f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 26 16:05:20 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 26 16:05:20 2015 -0500

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


