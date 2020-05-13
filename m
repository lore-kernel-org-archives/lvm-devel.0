From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 May 2020 22:27:23 +0000 (GMT)
Subject: master - devs: add some checks for a dev with no path name
Message-ID: <20200513222723.A13833858D34@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f29765e7fd1135d070310683cf486f07d041c81
Commit:        2f29765e7fd1135d070310683cf486f07d041c81
Parent:        2d1fe38d84d499011d13ae1ea11535398528fc87
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 13 15:47:20 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 13 16:26:26 2020 -0500

devs: add some checks for a dev with no path name

It's possible for a dev-cache entry to remain after all
paths for it have been removed, and other parts of the
code expect that a dev always has a name.  A better fix
may be to remove a device from dev-cache after all paths
to it have been removed.
---
 lib/device/dev-io.c | 3 +++
 lib/label/hints.c   | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 735441f19..33b9345ee 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -86,6 +86,9 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	int fd = dev->bcache_fd;
 	int do_close = 0;
 
+	if (dm_list_empty(&dev->aliases))
+		return 0;
+
 	if (dev->size_seqno == _dev_size_seqno) {
 		log_very_verbose("%s: using cached size %" PRIu64 " sectors",
 				 name, dev->size);
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 48fb661b4..349d5aaef 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -419,6 +419,9 @@ static int _dev_in_hint_hash(struct cmd_context *cmd, struct device *dev)
 {
 	uint64_t devsize = 0;
 
+	if (dm_list_empty(&dev->aliases))
+		return 0;
+
 	if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "regex"))
 		return 0;
 


