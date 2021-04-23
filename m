From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:36 +0000 (GMT)
Subject: main - pvscan: fix memleak
Message-ID: <20210423210536.BCC54393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65c4f81dc2eebe4096c48159f2fbd1107e284aea
Commit:        65c4f81dc2eebe4096c48159f2fbd1107e284aea
Parent:        5e8307f4bfc6e04cd601fea78129302ce02ffef8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 15:11:36 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 22:55:39 2021 +0200

pvscan: fix memleak

Commit 25b58310e3d606a85abc9bd50991ccb7ddcbfe25 add zalloc()
without correspoding free(), switch to use cmd mempool.
---
 tools/pvscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 22cb7bc18..83f3f3983 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -848,7 +848,7 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 			goto bad;
 		}
 
-		if (!(devl = zalloc(sizeof(*devl))))
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
 			goto_bad;
 
 		devl->dev = dev;


