From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:59:49 -0400
Subject: master - cleanup: fix some typos
Message-ID: <201707101259.v6ACxn7j027888@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7617e08c0398bbfef66a710e377884c0793afa56
Commit:        7617e08c0398bbfef66a710e377884c0793afa56
Parent:        4c943710059e51b3730fea385b7bd8ef34beecb2
Author:        Eric Ren <zren@suse.com>
AuthorDate:    Sun Jul 9 01:21:38 2017 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:58:33 2017 +0200

cleanup: fix some typos

form -> from
accomodate -> accommodate

Signed-off-by: Eric Ren <zren@suse.com>
---
 libdm/misc/dm-log-userspace.h |    2 +-
 tools/command.h               |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/misc/dm-log-userspace.h b/libdm/misc/dm-log-userspace.h
index 6418300..a770ae6 100644
--- a/libdm/misc/dm-log-userspace.h
+++ b/libdm/misc/dm-log-userspace.h
@@ -34,7 +34,7 @@
  *	opt = addr.nl_groups;
  *	setsockopt(fd, SOL_NETLINK, NETLINK_ADD_MEMBERSHIP, &opt, sizeof(opt));
  *
- * User-space will then wait to receive requests form the kernel, which it
+ * User-space will then wait to receive requests from the kernel, which it
  * will process as described below.  The requests are received in the form,
  * ((struct dm_ulog_request) + (additional data)).  Depending on the request
  * type, there may or may not be 'additional data'.  In the descriptions below,
diff --git a/tools/command.h b/tools/command.h
index a84e374..c2e3e6a 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -150,7 +150,7 @@ struct cmd_rule {
 /*
  * Array sizes
  *
- * CMD_RO_ARGS needs to accomodate a list of options,
+ * CMD_RO_ARGS needs to accommodate a list of options,
  * of which one is required after which the rest are
  * optional.
  */


