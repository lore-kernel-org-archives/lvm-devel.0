From: Eric Ren <zren@suse.com>
Date: Sun,  9 Jul 2017 01:21:38 +0800
Subject: [PATCH 2/3] cleanup: fix some typos
Message-ID: <20170708172138.19953-1-zren@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

form -> from
accomodate -> accommodate

Signed-off-by: Eric Ren <zren@suse.com>
---
 libdm/misc/dm-log-userspace.h | 2 +-
 tools/command.h               | 2 +-
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
-- 
2.10.2


