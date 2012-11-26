From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 26 Nov 2012 14:57:30 +0000 (UTC)
Subject: master - filters: Add STEC skd and Violin vtms devices
Message-ID: <20121126145730.D9FEE35F6@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c49aa79e7372a9cea9f7fe114d26a47cc81cdf4
Commit:        8c49aa79e7372a9cea9f7fe114d26a47cc81cdf4
Parent:        1ef98310187a7b287255cacd4b56160e48100d03
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 26 14:55:17 2012 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 26 14:55:17 2012 +0000

filters: Add STEC skd and Violin vtms devices

---
 WHATS_NEW                  |    2 ++
 lib/filters/device-types.h |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 85fcd3e..2c6ad4c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.99 - 
 ===================================
+  Recognise STEC skd devices in filter.
+  Recognise Violin Memory vtms devices in filter.
   Add lvm.conf thin pool defs thin_pool_{chunk_size|discards|zero}.
   Support discards for non-power-of-2 thin pool chunks.
   Automatically restore MISSING PVs with no MDAs.
diff --git a/lib/filters/device-types.h b/lib/filters/device-types.h
index 9efbe68..aec4293 100644
--- a/lib/filters/device-types.h
+++ b/lib/filters/device-types.h
@@ -56,5 +56,7 @@ static const device_info_t _device_info[] = {
 	{"blkext", 1},		/* Extended device partitions */
 	{"fio", 16},		/* Fusion */
 	{"mtip32xx", 16},	/* Micron PCIe SSDs */
+	{"vtms", 16},		/* Violin Memory */
+	{"skd", 16},		/* STEC */
 	{"", 0}
 };


