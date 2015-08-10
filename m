From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 10 Aug 2015 19:30:29 +0000 (UTC)
Subject: master - dmsetup: don't free handle if dm_stats_create fails (Coverity)
Message-ID: <20150810193029.A705F60D8B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec87e88c5264511576341286b474b453a15594ba
Commit:        ec87e88c5264511576341286b474b453a15594ba
Parent:        f9f5aac123d2244daeff92a692a03da3fea6bd74
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 10 19:05:10 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 10 20:25:59 2015 +0100

dmsetup: don't free handle if dm_stats_create fails (Coverity)

The error path of _stats_list frees the task and stats objects:
don't try to branch to it before they have been allocated.

tools/dmsetup.c: 4589 in _stats_help() - Null pointer dereferences  (FORWARD_NULL)
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 2ee432b..ed3cbd1 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4253,7 +4253,7 @@ static int _stats_list(CMD_ARGS)
 		return 1;
 
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
-		goto_out;
+		return_0;
 
 	if (!_bind_stats_device(dms, name))
 		goto_out;


