From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:47 +0000 (GMT)
Subject: main - make: fix compilation for some compiler
Message-ID: <20210927165747.9BAE0385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c85ea50de2fbdf2c923b0739171661ecdd63832
Commit:        6c85ea50de2fbdf2c923b0739171661ecdd63832
Parent:        ef21ed78ae5a3dd0b30e4b247ec3774347cadb4d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 17:18:30 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

make: fix compilation for some compiler

Reported-by: adamboardman of gemian
---
 tools/toollib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 606d35981..7e35f6f22 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -49,7 +49,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 	int null_fd;
 	pid_t pid;
 	struct sigaction act = {
-		{_sigchld_handler},
+		.sa_handler = _sigchld_handler,
 		.sa_flags = SA_NOCLDSTOP,
 	};
 


