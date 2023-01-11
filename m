From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 11 Jan 2023 12:35:22 +0000 (GMT)
Subject: main - lvmlockd: Fix syntax error in previous commit
Message-ID: <20230111123522.EDC9D3858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2ab81a3513f200d16d35b07cc8d510ba5d95c001
Commit:        2ab81a3513f200d16d35b07cc8d510ba5d95c001
Parent:        7c9c3ba5d59eef94c846e16d786e3ff4029516e5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jan 11 13:34:38 2023 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jan 11 13:34:38 2023 +0100

lvmlockd: Fix syntax error in previous commit

---
 lib/locking/lvmlockd.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 8628fa093..d486abc09 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -260,7 +260,7 @@ static inline int lockd_lv_refresh(struct cmd_context *cmd, struct lvresize_para
 	return 0;
 }
 
-static inline int lockd_query_lv(struct cmd_context *cmd, struct logical_volume *lv, int *ex, int *sh);
+static inline int lockd_query_lv(struct cmd_context *cmd, struct logical_volume *lv, int *ex, int *sh)
 {
 	return 0;
 }

