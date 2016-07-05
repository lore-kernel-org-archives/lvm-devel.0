From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:57 +0000 (UTC)
Subject: master - dmstats: allow --statstype to override report defults
Message-ID: <20160705185457.0823C612CA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=837e7e513b7438f6691c7ed8c4974841652e858a
Commit:        837e7e513b7438f6691c7ed8c4974841652e858a
Parent:        a2bf3c6ee8ae6e03bd1351e59f1a097c92205dec
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jun 29 10:19:28 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: allow --statstype to override report defults

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ae04c9d..8932921 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5122,7 +5122,7 @@ static int _stats_report(CMD_ARGS)
 		_statstype |= (DM_STATS_WALK_ALL
 			       | DM_STATS_WALK_SKIP_SINGLE_AREA);
 
-	if (!strcmp(subcommand, "report"))
+	if (!strcmp(subcommand, "report") && !_switches[STATSTYPE_ARG])
 		/* suppress duplicate rows of output */
 		_statstype |= (DM_STATS_WALK_ALL
 			       | DM_STATS_WALK_SKIP_SINGLE_AREA);


