From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:05:50 +0000 (UTC)
Subject: master - dmsetup: one missed dms
Message-ID: <20151109160550.C5BBC60222@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c331f3061269cc4a60e2b40f12f2dcb19a86994
Commit:        6c331f3061269cc4a60e2b40f12f2dcb19a86994
Parent:        32762e2a9c897723fa1c124f5ba723d430448902
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 16:02:33 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 17:04:10 2015 +0100

dmsetup: one missed dms

---
 tools/dmsetup.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index bfba753..1efffb6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4585,7 +4585,8 @@ static int _stats_clear(CMD_ARGS)
 	region_id = (allregions) ? DM_STATS_REGIONS_ALL
 		     : (uint64_t) _int_args[REGION_ID_ARG];
 
-	dms = dm_stats_create(DM_STATS_PROGRAM_ID);
+	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
+                return_0;
 
 	if (!_bind_stats_device(dms, name))
 		goto_out;


