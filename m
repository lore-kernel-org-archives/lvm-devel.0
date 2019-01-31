From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 Jan 2019 11:00:01 -0500
Subject: 2018-06-01-stable - lvmlockd: fix make lockstart wait
Message-ID: <201901311600.x0VG01K4010031@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0cb672466437161055ac084a5c1523b0eec1bf5
Commit:        d0cb672466437161055ac084a5c1523b0eec1bf5
Parent:        75886f59e46b7f9bcb2149d159a4867adb05ba0d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 16 13:24:29 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 31 09:56:29 2019 -0600

lvmlockd: fix make lockstart wait

when building without lvmlockd
---
 lib/locking/lvmlockd.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 05a84e1..85d078b 100644
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


