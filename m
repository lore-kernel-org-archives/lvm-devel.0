From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:11 +0000 (UTC)
Subject: master - dmsetup: add missing checks for dm_stats_create() ret value
Message-ID: <20151109092811.C18BC60CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=297d6773afbddd747bc1c56fd01182b9ca798f60
Commit:        297d6773afbddd747bc1c56fd01182b9ca798f60
Parent:        e90c5d206043af53e868c785707dabf070fa5747
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:45:53 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

dmsetup: add missing checks for dm_stats_create() ret value

Coverity likes to see a check for dms not being NULL, so
add those missing ones...
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |   10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9e6a849..c735194 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.111 - 
 ====================================
+  Add checks for failing dm_stats_create() in dmsetup.
   Add missing fifo close when failed to initialize client connection.
 
 Version 1.02.110 - 30th October 2015
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a5cbef5..d6c0ad7 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4834,7 +4834,9 @@ static int _stats_create(CMD_ARGS)
 	if (_switches[AUX_DATA_ARG])
 		aux_data = _string_args[AUX_DATA_ARG];
 
-	dms = dm_stats_create(DM_STATS_PROGRAM_ID);
+	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
+		return_0;
+
 	if (!_bind_stats_device(dms, name))
 		goto_bad;
 
@@ -4906,7 +4908,8 @@ static int _stats_delete(CMD_ARGS)
 
 	region_id = (uint64_t) _int_args[REGION_ID_ARG];
 
-	dms = dm_stats_create(program_id);
+	if (!(dms = dm_stats_create(program_id)))
+		return_0;
 
 	if (!_bind_stats_device(dms, name))
 		goto_out;
@@ -4968,7 +4971,8 @@ static int _stats_print(CMD_ARGS)
 
 	region_id = (uint64_t) _int_args[REGION_ID_ARG];
 
-	dms = dm_stats_create(DM_STATS_PROGRAM_ID);
+	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
+		return_0;
 
 	if (!_bind_stats_device(dms, name))
 		goto_out;


