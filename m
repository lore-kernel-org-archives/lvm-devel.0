From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 14:41:07 -0400
Subject: master - man-generator: shutdown stdout buffer
Message-ID: <201703301841.v2UIf7LV030352@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92ac1da16af40d5ec81a00c24b07199447fd0989
Commit:        92ac1da16af40d5ec81a00c24b07199447fd0989
Parent:        2c4e8254de59579a84b6c1f3dcc66868b3e9ef34
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 20:40:44 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 20:40:44 2017 +0200

man-generator: shutdown stdout buffer

Flush stdout and switch it back to line buffering before exit.
---
 tools/command.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 7ed63c8..816901b 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3492,8 +3492,11 @@ int main(int argc, char *argv[])
 	}
 
 out_free:
-	if (stdout_buf)
+	if (stdout_buf) {
+		fflush(stdout);
+		setlinebuf(stdout);
 		free(stdout_buf);
+	}
 
 	exit(r ? EXIT_SUCCESS: EXIT_FAILURE);
 }


