From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 18 Feb 2015 11:47:35 +0000 (UTC)
Subject: master - clvmd: Fix BZ 1140095 by updating lastfd upon EINTR.
Message-ID: <20150218114735.69D7160EE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=373f8556847a8fdbed3cedd687691d716dca4c5a
Commit:        373f8556847a8fdbed3cedd687691d716dca4c5a
Parent:        88411fb6f97937c6cac573e2720ae30fafe96761
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Feb 18 12:45:43 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Feb 18 12:45:43 2015 +0100

clvmd: Fix BZ 1140095 by updating lastfd upon EINTR.

---
 daemons/clvmd/clvmd.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 5cd6874..a7f98a0 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -899,8 +899,10 @@ static void main_loop(int cmd_timeout)
 					ret = thisfd->callback(thisfd, buf, sizeof(buf),
 							       csid, &newfd);
 					/* Ignore EAGAIN */
-					if (ret < 0 && (errno == EAGAIN || errno == EINTR))
+					if (ret < 0 && (errno == EAGAIN || errno == EINTR)) {
+						lastfd = thisfd;
 						continue;
+                                        }
 
 					/* Got error or EOF: Remove it from the list safely */
 					if (ret <= 0) {


