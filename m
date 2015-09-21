From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 21 Sep 2015 22:11:50 +0000 (UTC)
Subject: master - clvmd: update help test
Message-ID: <20150921221150.9267F60E20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a61f3c531650e4473291ff162dd4c9faf5888a39
Commit:        a61f3c531650e4473291ff162dd4c9faf5888a39
Parent:        ce80d736848135851bb9961cec8cb361911fe455
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 21 22:40:49 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 00:08:44 2015 +0200

clvmd: update help test

Use <n> for <input> value.
---
 daemons/clvmd/clvmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index c6d51bd..53daa8c 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -154,7 +154,7 @@ static void usage(const char *prog, FILE *file)
 {
 	fprintf(file, "Usage: %s [options]\n"
 		"   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n"
-		"   -d[n]    Set debug logging (0:none, 1:stderr (implies -f option), 2:syslog)\n"
+		"   -d[<n>]  Set debug logging (0:none, 1:stderr (implies -f option), 2:syslog)\n"
 		"   -E<uuid> Take this lock uuid as exclusively locked resource (for restart)\n"
 		"   -f       Don't fork, run in the foreground\n"
 		"   -h       Show this help information\n"


