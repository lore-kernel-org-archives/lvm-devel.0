From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 16 Sep 2013 19:21:59 +0000 (UTC)
Subject: master - debug: Use // for commented out debug #defines
Message-ID: <20130916192159.D50F060F6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce9a5cc25712907f05aa780d53d727b16f5dfd7c
Commit:        ce9a5cc25712907f05aa780d53d727b16f5dfd7c
Parent:        36c5bb40a27c7faac2a167df8c5cbd7c98c5168d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 16 20:20:26 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 16 20:20:26 2013 +0100

debug: Use // for commented out debug #defines

The traditional style used for optional editable definitions
/* #define X	/* */
produces a bogus warning from gcc -Wall.

Rather than suppressing this with -Wno-comment, switch over to
the // comment style.
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index bccebb6..83789df 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -66,7 +66,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 			  strerror(errno));
 
 /* Set this to avoid discarding output from background process */
-/* #define DEBUG_CHILD */
+// #define DEBUG_CHILD
 
 #ifndef DEBUG_CHILD
 	if ((null_fd = open(devnull, O_RDWR)) == -1) {


