From: David Teigland <teigland@sourceware.org>
Date: Fri, 4 Oct 2019 11:10:07 -0400
Subject: master - lvmlockd: set failure flag for test mode
Message-ID: <201910041510.x94FA72u028558@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a68258339da7e56910a2a3f6f98e43424ac219b6
Commit:        a68258339da7e56910a2a3f6f98e43424ac219b6
Parent:        b20b23dfc6bef6f0e468f8331b277e974d1fea12
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 4 10:07:24 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 4 10:09:49 2019 -0500

lvmlockd: set failure flag for test mode

Set a failure flag when vg_read returns an error
for test mode.  The caller can segfault if there's
an error with no flag set.
---
 lib/metadata/metadata.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index cf5c563..39544e6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3902,6 +3902,7 @@ static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg
 
 	if (test_mode()) {
 		log_error("Test mode is not yet supported with lock type %s.", vg->lock_type);
+		*failure |= FAILED_LOCK_TYPE;
 		return 0;
 	}
 


