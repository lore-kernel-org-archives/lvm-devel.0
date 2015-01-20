From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:44:37 +0000 (UTC)
Subject: master - thin: support errorwhenfull with thin creation
Message-ID: <20150120144437.EC22E61040@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75b786c5ef557b690e5638b6702ad19f20cb13f1
Commit:        75b786c5ef557b690e5638b6702ad19f20cb13f1
Parent:        a625812bec4597adb6e71816130dacac2ff38b34
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 20 15:43:16 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 15:43:16 2015 +0100

thin: support errorwhenfull with thin creation

When thinpool and thinvolume are created at the same time,
still support usage of --errorwhenfull.
---
 tools/lvcreate.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index fd5ac39..3f7fe6f 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -951,7 +951,8 @@ static int _lvcreate_params(struct cmd_context *cmd,
 				 -1))
 		return_0;
 
-	if (!seg_can_error_when_full(lp) && arg_is_set(cmd, errorwhenfull_ARG)) {
+	if (!seg_can_error_when_full(lp) && !lp->create_pool &&
+	    arg_is_set(cmd, errorwhenfull_ARG)) {
 		log_error("Segment type %s does not support --errorwhenfull.", lp->segtype->name);
 		return 0;
 	}


