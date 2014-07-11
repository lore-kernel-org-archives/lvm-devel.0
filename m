From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 12:12:42 +0000 (UTC)
Subject: master - lvconvert: fix mirror path
Message-ID: <20140711121242.24B6661110@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0ebe78ef89e2a29d2dacc40184e41970ffc5564
Commit:        c0ebe78ef89e2a29d2dacc40184e41970ffc5564
Parent:        17b92001ea4093e01d93ebd3645aa935896b9940
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 14:09:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 14:12:35 2014 +0200

lvconvert: fix mirror path

lvconvert rewrite commit missed proper handling
of mirror path for --corelog and --mirrorlog options.
Document this even in man page.
---
 man/lvconvert.8.in |    2 ++
 tools/lvconvert.c  |    4 +++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index e038371..032fbff 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -169,7 +169,9 @@ See \fBlvm\fP(8) for common options.
 .br
 Exactly one of
 .BR \-\-cache ,
+.BR \-\-corelog ,
 .BR \-\-merge ,
+.BR \-\-mirrorlog ,
 .BR \-\-mirrors ,
 .BR \-\-repair ,
 .BR \-\-replace ,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 04bb202..c51158b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -616,7 +616,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 								    tmp_str)))
 				return_0;
 		}
-	} else if (_mirror_or_raid_type_requested(cmd, type_str)) { /* Mirrors (and some RAID functions) */
+	} else if (_mirror_or_raid_type_requested(cmd, type_str) ||
+		   arg_is_set(cmd, mirrorlog_ARG) ||
+		   arg_is_set(cmd, corelog_ARG)) { /* Mirrors (and some RAID functions) */
 		if (arg_count(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with snapshots or pools.");
 			return 0;


