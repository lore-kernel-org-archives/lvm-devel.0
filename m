From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 30 Aug 2018 07:16:21 -0400
Subject: master - scripts: lvm2-activation-generator: also log possible execv error
Message-ID: <201808301116.w7UBGL3g012951@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=03ed2aae3a54afcc521a1af9b8a62827c1fb76d6
Commit:        03ed2aae3a54afcc521a1af9b8a62827c1fb76d6
Parent:        3d5c4847b663c42573ffabba7f26f30196f54d82
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 30 12:48:50 2018 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 30 13:14:10 2018 +0200

scripts: lvm2-activation-generator: also log possible execv error

---
 scripts/generator-internals.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
index c38323b..00a15e5 100644
--- a/scripts/generator-internals.c
+++ b/scripts/generator-internals.c
@@ -56,7 +56,8 @@ static bool _open_child(struct child_process *child, const char *cmd, const char
 			close(pipe_fd[1]);
 		}
 
-		execv(cmd, (char *const *) argv);
+		if (execv(cmd, (char *const *) argv) < 0)
+			_error("execv failed: %s\n", strerror(errno));
 		// Shouldn't get here unless exec failed.
 		exit(1);
 	} else {


