From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 10 Aug 2015 19:30:23 +0000 (UTC)
Subject: master - dmsetup: remove bogus !_report test in _stats_report (Coverity)
Message-ID: <20150810193023.4707760B61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b74824985f7e4e90f0ba9668724abd08d5fef74
Commit:        3b74824985f7e4e90f0ba9668724abd08d5fef74
Parent:        6bd5bf3cb5a1c01ec8be8bb714c7c0461d6bec58
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 10 10:01:18 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 10 20:12:53 2015 +0100

dmsetup: remove bogus !_report test in _stats_report (Coverity)

There's no point testing _report here in _stats_report: it's always
initialised before the function is called and if the check did fail
we'd end up freeing an uninitialized dm_task in the error path.

tools/dmsetup.c: 4389 in _stats_report() - Declaring variable "dmt" without initializer.
---
 tools/dmsetup.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index de67b03..2ee432b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4397,9 +4397,6 @@ static int _stats_report(CMD_ARGS)
 		name = argv[1];
 	}
 
-	if (!_report)
-		goto out;
-
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
 		return 0;
 


