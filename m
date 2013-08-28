From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 28 Aug 2013 12:54:01 +0000 (UTC)
Subject: master - test: Set the timeout to 3 minutes (was 5s accidentally).
Message-ID: <20130828125401.D86A460FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b3664dc8dcfb5bf86be03f20e62617e0c49f5ec
Commit:        8b3664dc8dcfb5bf86be03f20e62617e0c49f5ec
Parent:        64fe17dc94ce3b7cc547c9fc544c34460d99d5b3
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Aug 23 18:11:22 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 28 14:53:23 2013 +0200

test: Set the timeout to 3 minutes (was 5s accidentally).

---
 test/lib/harness.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index af30c44..52fa62f 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -381,7 +381,7 @@ static void run(int i, char *f) {
 		FD_SET(fds[1], &master_set);
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
-			    time(NULL) - start > 5) // a 2 minute timeout
+			    time(NULL) - start > 180) // a 3 minute timeout
 			{
 				system("echo t > /proc/sysrq-trigger");
 				kill(pid, SIGINT);


