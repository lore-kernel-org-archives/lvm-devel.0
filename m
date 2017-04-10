From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 10 Apr 2017 12:30:52 -0400
Subject: master - signals: fix comparison flaw
Message-ID: <201704101630.v3AGUq6M028570@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e21159a7f2c8d2806890b743866a0b9702e7532
Commit:        4e21159a7f2c8d2806890b743866a0b9702e7532
Parent:        9a689fb8f0a6b1675a4e819f4837bf2e0269832f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Apr 10 18:29:26 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Apr 10 18:29:26 2017 +0200

signals: fix comparison flaw

commit 9a689fb8f0a6b1675a4e819f4837bf2e0269832f
fixed SIGINT blocking but introduced a comparision
flaw to sigint_restore.

Related: rhbz1440766
---
 lib/misc/lvm-signal.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 15d8a6f..8a4ead4 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -98,7 +98,7 @@ void sigint_restore(void)
 		return;
 
 	if (!_handler_installed ||
-	    --_handler_installed > MAX_SIGINTS)
+	    --_handler_installed >= MAX_SIGINTS)
 		return;
 
 	/* Nesting count went below MAX_SIGINTS. */


