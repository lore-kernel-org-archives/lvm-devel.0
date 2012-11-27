From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Nov 2012 13:28:39 +0000 (UTC)
Subject: master - thin: fix attrs for unloaded driver
Message-ID: <20121127132839.667822385@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7a7fd0a12d0daef70e3c4517ccdef6830c7a34e
Commit:        c7a7fd0a12d0daef70e3c4517ccdef6830c7a34e
Parent:        8c49aa79e7372a9cea9f7fe114d26a47cc81cdf4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 26 11:05:30 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 27 11:29:47 2012 +0100

thin: fix attrs for unloaded driver

If the driver is not loaded, set all 'features' ON
instead of all of them being OFF.
---
 tools/lvconvert.c |    1 +
 tools/lvcreate.c  |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fc58add..e428ce0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -157,6 +157,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	int pagesize = lvm_getpagesize();
 
 	memset(lp, 0, sizeof(*lp));
+	lp->target_attr = ~0;
 
 	if ((arg_count(cmd, snapshot_ARG) || arg_count(cmd, merge_ARG)) &&
 	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG) ||
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0d76bbe..78292f7 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -659,6 +659,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
 	dm_list_init(&lp->tags);
+	lp->target_attr = ~0;
 
 	/*
 	 * Check selected options are compatible and determine segtype


