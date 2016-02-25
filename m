From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:41:02 +0000 (UTC)
Subject: master - pvcreate: fix error from pv_write
Message-ID: <20160225224102.CD81560B47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=045d086a570d327b00a4a06d139b387d059ade60
Commit:        045d086a570d327b00a4a06d139b387d059ade60
Parent:        23a4801dbcc4d351db6c251685e08f3fec30cbdd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 25 16:38:59 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 16:40:24 2016 -0600

pvcreate: fix error from pv_write

After a pv_write() failure, the PV wasn't being skipped.
---
 tools/toollib.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8029030..dd5ece3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4452,6 +4452,7 @@ do_command:
 		if (!pv_write(cmd, pv, 0)) {
 			log_error("Failed to write physical volume \"%s\"", pv_name);
 			dm_list_move(&pp->arg_fail, &pd->list);
+			continue;
 		}
 
 		log_print_unless_silent("Physical volume \"%s\" successfully created", pv_name);


