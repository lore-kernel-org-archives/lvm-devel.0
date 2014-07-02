From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:50 +0000 (UTC)
Subject: master - cleanup: line indent
Message-ID: <20140702084850.6833361054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b3a49876eb36b5b97e7fbd7935208f0d85607e0
Commit:        6b3a49876eb36b5b97e7fbd7935208f0d85607e0
Parent:        748af97afc30d65a9b89d877fdbd2e12ea8fb8e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 1 10:17:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:42 2014 +0200

cleanup: line indent

---
 tools/lvconvert.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ca58a1f..a6187a0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -305,7 +305,8 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 		if (mirror_or_raid_type_requested(cmd, type_str)) {
-			log_error("--%spool and --mirrors/--type mirror/--type raid* are mutually exlusive.", cache_pool ? "type cache_" : "thin");
+			log_error("--%spool and --mirrors/--type mirror/--type raid* are mutually exlusive.",
+				  cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
 		if (arg_count(cmd, repair_ARG)) {
@@ -314,11 +315,13 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 		if (snapshot_type_requested(cmd, type_str)) {
-			log_error("--%spool and --snapshot/--type snapshot are mutually exlusive.", cache_pool ? "type cache_" : "thin");
+			log_error("--%spool and --snapshot/--type snapshot are mutually exlusive.",
+				  cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
 		if (arg_count(cmd, splitmirrors_ARG)) {
-			log_error("--%spool and --splitmirrors are mutually exlusive.", cache_pool ? "type cache_" : "thin");
+			log_error("--%spool and --splitmirrors are mutually exlusive.",
+				  cache_pool ? "type cache_" : "thin");
 			return 0;
 		}
 		if (!cache_pool)


