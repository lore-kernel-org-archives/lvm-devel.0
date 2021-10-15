From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 21:42:21 +0000 (GMT)
Subject: main - cov: validate subcommand existance
Message-ID: <20211015214221.AEB9A3858401@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6668d6409aa841839b8eefc2a49d004b0c29397a
Commit:        6668d6409aa841839b8eefc2a49d004b0c29397a
Parent:        2779830a060730801ae6b055c2332301bf913c0f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 14:42:20 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 23:39:25 2021 +0200

cov: validate subcommand existance

Before dereference of subcommand pointer, check it's not NULL
as  coverity believes there exists theoretical path for this...
---
 libdm/dm-tools/dmsetup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 07b6cca8a..8502d9adc 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -5846,12 +5846,12 @@ static int _stats_report(CMD_ARGS)
 	if (_switches[ALL_PROGRAMS_ARG])
 		_program_id = "";
 
-	if (_switches[VERBOSE_ARG] && !strcmp(subcommand, "list"))
+	if (_switches[VERBOSE_ARG] && subcommand && !strcmp(subcommand, "list"))
 		_statstype |= (DM_STATS_WALK_ALL
 			       | DM_STATS_WALK_SKIP_SINGLE_AREA);
 
 	/* suppress duplicates unless the user has requested all regions */
-	if (!strcmp(subcommand, "report") && !objtype_args)
+	if (subcommand && !objtype_args && !strcmp(subcommand, "report"))
 		/* suppress duplicate rows of output */
 		_statstype |= (DM_STATS_WALK_ALL
 			       | DM_STATS_WALK_SKIP_SINGLE_AREA);


