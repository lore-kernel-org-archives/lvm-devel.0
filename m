From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Sep 2013 10:21:54 +0000 (UTC)
Subject: master - cleanup: drop within comment gcc warning
Message-ID: <20130909102154.CE29060DD9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d89b514e06eb3431052d3dee4758103bf5f08963
Commit:        d89b514e06eb3431052d3dee4758103bf5f08963
Parent:        ac2de55d69605d058bbc7622638331549a0ba5c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 9 12:15:48 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 9 12:17:11 2013 +0200

cleanup: drop within comment gcc warning

toollib.c:69:24: warning: "/*" within comment
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 5868ac0..bccebb6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -66,7 +66,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 			  strerror(errno));
 
 /* Set this to avoid discarding output from background process */
-/* #define DEBUG_CHILD /* */
+/* #define DEBUG_CHILD */
 
 #ifndef DEBUG_CHILD
 	if ((null_fd = open(devnull, O_RDWR)) == -1) {


