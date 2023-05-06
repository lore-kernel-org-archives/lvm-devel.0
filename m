From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:07 +0000 (GMT)
Subject: main - cov: hide problem with 64bit time_t
Message-ID: <20230506204607.6E1323858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4fd2f433ad7d49b404a897c64191826e7b3c9f4c
Commit:        4fd2f433ad7d49b404a897c64191826e7b3c9f4c
Parent:        242bf56413f67dc3dd16770d420ced06eed0c4be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 14:05:12 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 19:22:05 2023 +0200

cov: hide problem with 64bit time_t

---
 lib/commands/toolcontext.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4e05f9078..22563528e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1506,7 +1506,7 @@ static void _init_rand(struct cmd_context *cmd)
 		return;
 	}
 
-	cmd->rand_seed = (unsigned) time(NULL) + (unsigned) getpid();
+	cmd->rand_seed = (unsigned) ((time(NULL) + getpid()) & 0xffffffff);
 	reset_lvm_errno(1);
 }
 

