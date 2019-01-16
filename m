From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Jan 2019 14:25:14 -0500
Subject: master - lvmlockd: fix make lockstart wait
Message-ID: <201901161925.x0GJPEqA031654@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=facd5209311d0f205229c6943fa3b2ef42fc981f
Commit:        facd5209311d0f205229c6943fa3b2ef42fc981f
Parent:        ebaaff3590b60933f6f1e2bfd010a86fc373f7eb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 16 13:24:29 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 16 13:24:29 2019 -0600

lvmlockd: fix make lockstart wait

when building without lvmlockd
---
 lib/locking/lvmlockd.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 1fbf765..e5ae331 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -148,7 +148,7 @@ static inline int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_g
 	return 1;
 }
 
-static inline int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init)
+static inline int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init, int *exists)
 {
 	return 0;
 }


