From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 28 Aug 2013 12:53:55 +0000 (UTC)
Subject: master - test: Remove a redundant drain() from the timeout path.
Message-ID: <20130828125355.9BAC260FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d07cf851e5e9f501a034ac69d9f544e7426ec82c
Commit:        d07cf851e5e9f501a034ac69d9f544e7426ec82c
Parent:        c1217e6881f6d679c0589078c00350f00c6bee10
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 5 21:12:39 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 28 14:53:23 2013 +0200

test: Remove a redundant drain() from the timeout path.

---
 test/lib/harness.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 586c5d3..af30c44 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -390,7 +390,6 @@ static void run(int i, char *f) {
 					kill(-pid, SIGKILL);
 					w = pid; // waitpid(pid, &st, NULL);
 				}
-				drain();
 				runaway = 1;
 				break;
 			}


