From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 10 Apr 2017 12:41:59 -0400
Subject: master - signals: fix comparison flaw
Message-ID: <201704101641.v3AGfx2T029451@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a14a8cef2ff1ae5c9c946bde5a885667288e24d3
Commit:        a14a8cef2ff1ae5c9c946bde5a885667288e24d3
Parent:        9a689fb8f0a6b1675a4e819f4837bf2e0269832f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Apr 10 18:29:26 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Apr 10 18:41:28 2017 +0200

signals: fix comparison flaw

commit 9a689fb8f0a6b1675a4e819f4837bf2e0269832f
fixed SIGINT blocking but introduced a comparision
flaw to sigint_restore().

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


