From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 16 Nov 2017 14:13:33 -0500
Subject: master - lvmdiskscan: Remove unnecessary read.
Message-ID: <201711161913.vAGJDXMs031643@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=efb0e7ac6f5d4f12628f47c53c1a635b5e51dee5
Commit:        efb0e7ac6f5d4f12628f47c53c1a635b5e51dee5
Parent:        93c02e2532c71f5afe91605442a8acc059df982c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Nov 16 19:13:03 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Nov 16 19:13:03 2017 +0000

lvmdiskscan: Remove unnecessary read.

dev_get_size will open the device itself.
---
 WHATS_NEW           |    1 +
 tools/lvmdiskscan.c |   15 +--------------
 2 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ff60758..03d1e04 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Remove unnecessary single read from lvmdiskscan.
   Avoid using precommitted metadata for suspending pvmove tree.
   Ehnance pvmove locking.
   Deactivate activated LVs on error path when pvmove activation fails.
diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index bd0d705..cb688b5 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -69,28 +69,15 @@ static void _print(struct cmd_context *cmd, const struct device *dev,
 
 static int _check_device(struct cmd_context *cmd, struct device *dev)
 {
-	char buffer;
 	uint64_t size;
 
-	if (!dev_open_readonly(dev))
-		return_0;
-
-	if (!dev_read(dev, UINT64_C(0), (size_t) 1, &buffer)) {
-		stack;
-		if (!dev_close(dev))
-			stack;
-		return 0;
-	}
 	if (!dev_get_size(dev, &size)) {
 		log_error("Couldn't get size of \"%s\"", dev_name(dev));
 		size = 0;
 	}
 	_print(cmd, dev, size, NULL);
 	_count(dev, &disks_found, &parts_found);
-	if (!dev_close(dev)) {
-		log_error("dev_close on \"%s\" failed", dev_name(dev));
-		return 0;
-	}
+
 	return 1;
 }
 


