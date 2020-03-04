From: David Teigland <teigland@sourceware.org>
Date: Wed, 4 Mar 2020 09:58:42 -0500
Subject: master - pvck: fix reading large mda1
Message-ID: <202003041458.024EwgFD015635@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f140620043eb22b192e7d87e17a42fcd0a3656a1
Commit:        f140620043eb22b192e7d87e17a42fcd0a3656a1
Parent:        c6746181a3c2c40447f5a33e15359b57567f8217
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 2 15:22:39 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 13:47:07 2020 -0600

pvck: fix reading large mda1

When mda_size is larger than io_memory_size, reading
the entire mda fails unless the previous read of the
label has been invalidated.
---
 tools/pvck.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/pvck.c b/tools/pvck.c
index ab85537..79e3af5 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -981,6 +981,13 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 		return 0;
 	}
 
+	/*
+	 * Not invalidating this range can cause an error reading
+	 * a larger range that overlaps this.
+	 */
+	if (!dev_invalidate_bytes(dev, lh_offset, 512))
+		stack;
+
 	lh = (struct label_header *)buf;
 
 	if (print_fields) {



