From: David Teigland <teigland@sourceware.org>
Date: Mon, 18 Jun 2018 13:02:20 -0400
Subject: 2018-06-01-stable - bcache: remove extraneous error message
Message-ID: <201806181702.w5IH2K6h020967@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bfb904af1cb0a48a4ac44eb72179f628fda4fd03
Commit:        bfb904af1cb0a48a4ac44eb72179f628fda4fd03
Parent:        d88376ca78b711bca960e2e96c7ac723651f1d96
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 18 11:59:57 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 18 11:59:57 2018 -0500

bcache: remove extraneous error message

an error from io_submit is already recognized by
the caller like errors during completion.
---
 lib/device/bcache.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index ce50c0c..291184d 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -189,7 +189,6 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	} while (r == -EAGAIN);
 
 	if (r < 0) {
-		log_sys_warn("io_submit");
 		_cb_free(e->cbs, cb);
 		return false;
 	}


