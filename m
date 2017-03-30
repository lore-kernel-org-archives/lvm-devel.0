From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:03:57 -0400
Subject: master - dmfilemapd: make filemap_monitor->nr_regions uint64_t
Message-ID: <201703300903.v2U93v3I019889@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=660bd4fe3e86cc68d269ad707919f040b163f164
Commit:        660bd4fe3e86cc68d269ad707919f040b163f164
Parent:        ac6089ee8dce83bd61d90344bf67aeef8f319f41
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:23:57 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 09:57:58 2017 +0100

dmfilemapd: make filemap_monitor->nr_regions uint64_t

---
 daemons/dmfilemapd/dmfilemapd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index dd1db03..225335c 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -55,7 +55,7 @@ struct filemap_monitor {
 
 	/* monitoring heuristics */
 	int64_t blocks; /* allocated blocks, from stat.st_blocks */
-	int64_t nr_regions;
+	uint64_t nr_regions;
 	int deleted;
 };
 


