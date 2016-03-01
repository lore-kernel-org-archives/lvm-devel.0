From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Mar 2016 16:22:08 +0000 (UTC)
Subject: master - cleanup: missplaced .
Message-ID: <20160301162208.57A1260BDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=afae3355f8e79b8fab8d5bc45f99caf0d8b2420c
Commit:        afae3355f8e79b8fab8d5bc45f99caf0d8b2420c
Parent:        058eb3739d6f0550f81fb9d6268feda698fdbb05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 1 17:20:47 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 1 17:20:47 2016 +0100

cleanup: missplaced .

Remove misplaced '.' after '?'
Drop extra   'stack;'  after log_debug().
---
 tools/toollib.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 05d765d..dba5023 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3958,7 +3958,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	 */
 	if (!dev_test_excl(pv->dev)) {
 		/* FIXME Detect whether device-mapper itself is still using it */
-		log_error("Can't open %s exclusively.  Mounted filesystem?.",
+		log_error("Can't open %s exclusively.  Mounted filesystem?",
 			  pv_dev_name(pv));
 		dm_list_move(&pp->arg_fail, &pd->list);
 		return 1;
@@ -4049,6 +4049,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 
 	pd->dev = pv->dev;
 	dm_list_move(&pp->arg_process, &pd->list);
+
 	return 1;
 }
 
@@ -4193,7 +4194,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 */
 	if (dm_list_empty(&pp->arg_process)) {
 		log_debug("No devices to process.");
-		goto_bad;
+		goto bad;
 	}
 
 	/*


