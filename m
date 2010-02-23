From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 23 Feb 2010 13:45:06 -0500
Subject: [RFC][PATCH 2/4] dm-log: update resume method for interruption of presuspend
Message-ID: <4B842232.30604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When suspend is interrupted after presuspend procedure, each
target needs to cancel all state changes done by its presuspend
procedure. As for the log target, there is nothing to be canceled
because the log target doesn't have a presuspend method.

The log target should skip disk_resume/core_resume method when
the target isn't suspended.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 drivers/md/dm-log.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux-2.6.33-rc1-dm/drivers/md/dm-log.c
===================================================================
--- linux-2.6.33-rc1-dm.orig/drivers/md/dm-log.c
+++ linux-2.6.33-rc1-dm/drivers/md/dm-log.c
@@ -593,6 +593,10 @@ static int disk_resume(struct dm_dirty_l
 	struct log_c *lc = (struct log_c *) log->context;
 	size_t size = lc->bitset_uint32_count * sizeof(uint32_t);
 
+	/* Just returns if the state is not "suspended." */
+	if (!dm_suspended(lc->ti))
+		return 0;
+
 	/* read the disk header */
 	r = read_header(lc);
 	if (r) {
@@ -658,6 +662,11 @@ static uint32_t core_get_region_size(str
 static int core_resume(struct dm_dirty_log *log)
 {
 	struct log_c *lc = (struct log_c *) log->context;
+
+	/* Just returns if the state is not "suspended." */
+	if (!dm_suspended(lc->ti))
+		return 0;
+
 	lc->sync_search = 0;
 	return 0;
 }


