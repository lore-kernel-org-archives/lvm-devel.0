From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jun 2019 15:39:34 -0400
Subject: master - locking: fix repeated convert to ex
Message-ID: <201906101939.x5AJdYqg006168@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7850faba72a50e49783a3b01e6833fc1a99873b
Commit:        b7850faba72a50e49783a3b01e6833fc1a99873b
Parent:        49b884656725a39a33a5e27dd6377443e7e177e4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 10 12:04:49 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 10 13:37:03 2019 -0500

locking: fix repeated convert to ex

Some uncommon commands like pvchange -a -u may
call convert to ex multiple times.
---
 lib/locking/locking.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index c3ea536..3058a8b 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -384,6 +384,10 @@ int lockf_global(struct cmd_context *cmd, const char *mode)
 
 int lockf_global_convert(struct cmd_context *cmd, const char *mode)
 {
+	/* some uncommon cases like pvchange -a can call this multiple times */
+	if (cmd->lockf_global_ex && !strcmp(mode, "ex"))
+		return 1;
+
 	return _lockf_global(cmd, mode, 1);
 }
 


