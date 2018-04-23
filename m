From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:50:01 -0400
Subject: master - scan: handle request to scan missing dev
Message-ID: <201804231350.w3NDo1uI031785@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4f478d86d6545f6cced7a8ba3bc0b79dccb7b6e
Commit:        e4f478d86d6545f6cced7a8ba3bc0b79dccb7b6e
Parent:        89f54a5094981c827ca557cb1381e5f1a028912c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 13 16:17:02 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: handle request to scan missing dev

---
 lib/label/label.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 1268498..19beecf 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -257,6 +257,8 @@ struct bcache *scan_bcache;
 
 static bool _in_bcache(struct device *dev)
 {
+	if (!dev)
+		return NULL;
 	return (dev->flags & DEV_IN_BCACHE) ? true : false;
 }
 
@@ -402,6 +404,9 @@ static int _scan_dev_open(struct device *dev)
 	int flags = 0;
 	int fd;
 
+	if (!dev)
+		return 0;
+
 	if (dev->flags & DEV_IN_BCACHE) {
 		log_error("scan_dev_open %s DEV_IN_BCACHE already set", dev_name(dev));
 		dev->flags &= ~DEV_IN_BCACHE;


