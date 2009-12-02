From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed,  2 Dec 2009 14:49:33 -0500
Subject: [PATCH 1/2] Fix setting of readahead in lvcreate.
In-Reply-To: <1259783374-16394-1-git-send-email-dwysocha@redhat.com>
References: <1259783374-16394-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1259783374-16394-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The default comes from the configuration settings, with possible
commandline override.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv_manip.c |    2 +-
 tools/lvcreate.c        |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 38dcbf3..c440278 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3019,7 +3019,7 @@ int lv_create_single(struct volume_group *vg,
 				   status, lp->alloc, vg)))
 		return_0;
 
-	if (lp->read_ahead) {
+	if (lp->read_ahead != lv->read_ahead) {
 		log_verbose("Setting read ahead sectors");
 		lv->read_ahead = lp->read_ahead;
 	}
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2b2d135..06f3478 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -509,7 +509,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	/*
 	 * Read ahead.
 	 */
-	lp->read_ahead = arg_uint_value(cmd, readahead_ARG, DM_READ_AHEAD_NONE);
+	lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
+					cmd->default_settings.read_ahead);
 	pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
 	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
 	    lp->read_ahead != DM_READ_AHEAD_NONE &&
-- 
1.6.0.6


