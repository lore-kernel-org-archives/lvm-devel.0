From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Sep 2019 17:38:52 -0400
Subject: master - pvck: handle PVs with zero metadata copies
Message-ID: <201909302138.x8ULcqq3009876@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7368cf8e7df0218d61c9538fee68d0da634b5571
Commit:        7368cf8e7df0218d61c9538fee68d0da634b5571
Parent:        1bfae5bf8e5905a72f7168562e1bbc074f23b791
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 30 16:20:17 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 30 16:20:17 2019 -0500

pvck: handle PVs with zero metadata copies

---
 test/shell/pvck-dump.sh |   14 +++++++++++++-
 tools/pvck.c            |   23 +++++++++++++++++++----
 2 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index ed8766a..542fb49 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -12,30 +12,35 @@
 
 . lib/inittest
 
-aux prepare_devs 3
+aux prepare_devs 4
 get_devs
 
 dd if=/dev/zero of="$dev1" || true
 dd if=/dev/zero of="$dev2" || true
 dd if=/dev/zero of="$dev3" || true
+dd if=/dev/zero of="$dev4" || true
 
 pvcreate "$dev1"
 pvcreate "$dev2"
 pvcreate --pvmetadatacopies 2 "$dev3"
+pvcreate --pvmetadatacopies 0 "$dev4"
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
 pvck --dump headers "$dev1" > h1
 pvck --dump headers "$dev2" > h2
 pvck --dump headers "$dev3" > h3
+pvck --dump headers "$dev4" > h4
 
 grep "label_header at 512" h1
 grep "label_header at 512" h2
 grep "label_header at 512" h3
+grep "label_header at 512" h4
 
 grep "pv_header at 544" h1
 grep "pv_header at 544" h2
 grep "pv_header at 544" h3
+grep "pv_header at 544" h4
 
 grep "pv_header.disk_locn\[0\].offset 1048576" h1
 grep "pv_header.disk_locn\[0\].offset 1048576" h2
@@ -49,6 +54,10 @@ grep "pv_header.disk_locn\[2\].size 1044480" h1
 grep "pv_header.disk_locn\[2\].size 1044480" h2
 grep "pv_header.disk_locn\[2\].size 1044480" h3
 
+not grep "pv_header.disk_locn\[3\].size" h4
+not grep "pv_header.disk_locn\[4\].size" h4
+not grep "mda_header" h4
+
 grep "mda_header_1 at 4096" h1
 grep "mda_header_1 at 4096" h2
 grep "mda_header_1 at 4096" h3
@@ -75,8 +84,11 @@ not grep CHECK h3
 pvck --dump metadata "$dev1" > m1
 pvck --dump metadata "$dev2" > m2
 pvck --dump metadata "$dev3" > m3
+pvck --dump metadata "$dev4" > m4
 pvck --dump metadata --pvmetadatacopies 2 "$dev3" > m3b
 
+grep "zero metadata copies" m4
+
 diff m1 m2
 diff m1 m3
 
diff --git a/tools/pvck.c b/tools/pvck.c
index af2dd8e..2b5e63b 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -740,7 +740,8 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 				     struct device *dev,
 				     int *found_label,
 				     uint64_t *mda1_offset, uint64_t *mda1_size,
-				     uint64_t *mda2_offset, uint64_t *mda2_size)
+				     uint64_t *mda2_offset, uint64_t *mda2_size,
+				     int *mda_count_out)
 {
 	char str[256];
 	struct label_header *lh;
@@ -900,6 +901,8 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 		mda_count++;
 	}
 
+	*mda_count_out = mda_count;
+
 	/* all-zero dlocn struct is area list end */
 	if (print_fields) {
 		log_print("pv_header.disk_locn[%d] at %llu # location list end", di,
@@ -1117,6 +1120,7 @@ static int _dump_headers(struct cmd_context *cmd,
 	const char *pv_name;
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum, mda2_checksum;
+	int mda_count = 0;
 	int bad = 0;
 
 	pv_name = argv[0];
@@ -1129,9 +1133,14 @@ static int _dump_headers(struct cmd_context *cmd,
 	label_scan_setup_bcache();
 
 	if (!_dump_label_and_pv_header(cmd, 1, dev, NULL,
-			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size))
+			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
+	if (!mda_count) {
+		log_print("zero metadata copies");
+		return ECMD_PROCESSED;
+	}
+
 	/* N.B. mda1_size and mda2_size may be different */
 
 	/*
@@ -1180,6 +1189,7 @@ static int _dump_metadata(struct cmd_context *cmd,
 	const char *tofile = NULL;
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum, mda2_checksum;
+	int mda_count = 0;
 	int mda_num = 1;
 	int bad = 0;
 
@@ -1202,9 +1212,13 @@ static int _dump_metadata(struct cmd_context *cmd,
 	label_scan_setup_bcache();
 
 	if (!_dump_label_and_pv_header(cmd, 0, dev, NULL,
-			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size))
+			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
+	if (!mda_count) {
+		log_print("zero metadata copies");
+		return ECMD_PROCESSED;
+	}
 
 	/*
 	 * The first mda is always 4096 bytes from the start of the device.
@@ -1249,10 +1263,11 @@ static int _dump_found(struct cmd_context *cmd, struct device *dev,
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum = 0, mda2_checksum = 0;
 	int found_label = 0, found_header1 = 0, found_header2 = 0;
+	int mda_count = 0;
 	int bad = 0;
 
 	if (!_dump_label_and_pv_header(cmd, 0, dev, &found_label,
-			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size))
+			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
 	if (found_label && mda1_offset) {


