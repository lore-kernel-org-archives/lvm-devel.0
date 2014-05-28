From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 May 2014 13:36:06 +0000 (UTC)
Subject: master - revert: restore original timeout
Message-ID: <20140528133606.B035D6061F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2adaef82722ec71620a6d02c6c973d3472d705ae
Commit:        2adaef82722ec71620a6d02c6c973d3472d705ae
Parent:        171a668e81d9c647677465f042775722a35c5a6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 28 15:27:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 28 15:33:41 2014 +0200

revert: restore original timeout

Accidently it's been commited - but it has also shown,
that on heavy loaded systems (like our test machine could be)
slightly bigger timeouts which waits longer for udev rules
processing does help and avoids occasional refuse of deactivation
because device is still being open.
(i.e. lvcreate...; lvchange -an...)

Unsure how we could now synchronize for this. On very slow(/loaded)
system 5 second timeout is simply not enough.

TODO: introduce at least lvm.conf configurable setting to
allow longer 'retry' loops.
---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7ad3654..41d74c7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -726,7 +726,7 @@ int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
 			return 0;
 		}
 
-		usleep(OPEN_COUNT_CHECK_USLEEP_DELAY * 4);
+		usleep(OPEN_COUNT_CHECK_USLEEP_DELAY);
 		log_debug_activation("Retrying open_count check for %s/%s.",
 				     lv->vg->name, lv->name);
 		if (!lv_info(cmd, lv, 0, info, 1, 0)) {


