From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:08 -0400
Subject: master - lvmetad: need to set up bcache in another place
Message-ID: <201804231352.w3NDq8hO000327@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e351f8bc66d49fecaa0ab78f8413d50a4674604a
Commit:        e351f8bc66d49fecaa0ab78f8413d50a4674604a
Parent:        7e33bd1335ba91d6b978df3a39250987d3412116
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 6 15:05:27 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

lvmetad: need to set up bcache in another place

We need to find one common place to set up bcache
for the lvmetad case, instead of adding calls in
various places.
---
 lib/label/label.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 82d4bf3..9401067 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -675,6 +675,13 @@ int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs)
 {
 	struct device_list *devl;
 
+	/* FIXME: get rid of this, it's only needed for lvmetad in which
+	   case we should be setting up bcache in one place. */
+	if (!scan_bcache) {
+		if (!_setup_bcache(0))
+			return 0;
+	}
+
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
 			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);


