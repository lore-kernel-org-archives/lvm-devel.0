From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:45 +0000 (UTC)
Subject: dev-mornfall-activate - tests: bigger alignment
Message-ID: <20130604192845.DAC7C60FD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb2c68590b766e25ada9d425ad0b6602cd724fcc
Commit:        eb2c68590b766e25ada9d425ad0b6602cd724fcc
Parent:        803b7af70660332ce001c55fb9bc9e8511985421
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 2 23:57:53 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 3 08:42:34 2013 +0200

tests: bigger alignment

Test names got a bit longer...
---
 test/lib/harness.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index e80efbf..e98c7d6 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -310,7 +310,7 @@ static void run(int i, char *f) {
 		char buf[128];
 		snprintf(buf, 128, "%s ...", f);
 		buf[127] = 0;
-		printf("Running %-50s ", buf);
+		printf("Running %-60s ", buf);
 		fflush(stdout);
 		char outpath[512];
 		sprintf(outpath, "results/%s.txt", f);


