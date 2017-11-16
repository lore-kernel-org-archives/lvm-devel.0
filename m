From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 16 Nov 2017 14:17:34 -0500
Subject: master - device: log debug when I/O bounce buffer used
Message-ID: <201711161917.vAGJHYbl000611@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=115e66e9bedaa5d6edfd436fb78aba2c753deeb7
Commit:        115e66e9bedaa5d6edfd436fb78aba2c753deeb7
Parent:        efb0e7ac6f5d4f12628f47c53c1a635b5e51dee5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Nov 16 19:16:10 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Nov 16 19:16:10 2017 +0000

device: log debug when I/O bounce buffer used

---
 lib/device/dev-io.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 24bc81c..35c510f 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -234,6 +234,9 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	    !((uintptr_t) buffer & mask))
 		return _io(where, buffer, should_write);
 
+	log_debug_io("Widening request for %" PRIu64 " bytes at %" PRIu64 " to %" PRIu64 " bytes at %" PRIu64 " on %s",
+		     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev));
+
 	/* Allocate a bounce buffer with an extra block */
 	if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
 		log_error("Bounce buffer malloc failed");


