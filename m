From: David Teigland <teigland@sourceware.org>
Date: Tue, 2 Apr 2019 11:56:23 -0400
Subject: master - lvresize: fix when compiled without lvmlockd
Message-ID: <201904021556.x32FuNkt014037@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f471f0184aaac7499a33b32efb708aa8153a2af
Commit:        2f471f0184aaac7499a33b32efb708aa8153a2af
Parent:        27cfeb1d39b2515b9c4b81a1d217e05ae954a68b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 2 10:50:12 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 2 10:51:38 2019 -0500

lvresize: fix when compiled without lvmlockd

The no-op result of lockd_lv_resize should be success.
---
 lib/locking/lvmlockd.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index ecd39bb..e11ea15 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -215,7 +215,7 @@ static inline int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 static inline int lockd_lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	     const char *def_mode, uint32_t flags, struct lvresize_params *lp)
 {
-	return 0;
+	return 1;
 }
 
 static inline int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg,


