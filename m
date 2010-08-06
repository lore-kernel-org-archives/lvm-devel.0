From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 6 Aug 2010 00:11:39 -0400
Subject: [RFC PATCH v2] change default alignment of pe_start to 1MB
In-Reply-To: <20100805191001.GA27237@redhat.com>
References: <20100805191001.GA27237@redhat.com>
Message-ID: <20100806041138.GA29995@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The switch to a 1MB default alignment causes various tests in the LVM2
testsuite to fail -- not a big deal but the tests would need updating.

Of more concern is that the existing LVM2 set_pe_align() code doesn't
always properly respect the alignment determined from
'devices/md_chunk_alignment' or 'devices/data_alignment_detection'.

With the previous default alignment of 64k it would generally do the
right thing -- use the detected values.  But switching the default to
the larger value exposes the fact that MAX() of the MD or I/O Topology
detected values will generally always be 1MB -- when they are compared
to 1MB.

The following revised patch changes the LVM alignment detection
semantics to model what fdisk has elected to do:
- If the default value (1MB) is a multiple of the specified/detected
  alignment then just use the default.
- Otherwise, use the specified/detected value.

In practice this means we'll almost always use 1MB -- that is unless:
- the specified --dataalignment, MD's full stripe width, or the
  optimal_io_size exceeds 1MB
- the specified/detected value is not a power-of-2

NOTE: even with a default of 64k the old set_pe_align code would result
in incorrect alignment if a value < 64k were used for --dataalignment

---
 doc/example.conf.in     |    2 +-
 lib/metadata/metadata.c |   30 ++++++++++++++++++------------
 2 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 850b7e2..f7dcc63 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -113,7 +113,7 @@ devices {
     # Alignment (in KB) of start of data area when creating a new PV.
     # If a PV is placed directly upon an md device and md_chunk_alignment or
     # data_alignment_detection is enabled this parameter is ignored.
-    # Set to 0 for the default alignment of 64KB or page size, if larger.
+    # Set to 0 for the default alignment of 1MB or page size, if larger.
     data_alignment = 0
 
     # By default, the start of the PV's aligned data area will be shifted by
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d7edf54..469473a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -64,13 +64,16 @@ const char _really_init[] =
 
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
+	unsigned long temp_pe_align, default_pe_align = 2048;
+
 	if (pv->pe_align)
 		goto out;
 
 	if (data_alignment)
 		pv->pe_align = data_alignment;
 	else
-		pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
+		pv->pe_align = MAX((default_pe_align << SECTOR_SHIFT),
+				   lvm_getpagesize()) >> SECTOR_SHIFT;
 
 	if (!pv->dev)
 		goto out;
@@ -79,10 +82,11 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 * Align to stripe-width of underlying md device if present
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
-				  DEFAULT_MD_CHUNK_ALIGNMENT))
-		pv->pe_align = MAX(pv->pe_align,
-				   dev_md_stripe_width(pv->fmt->cmd->sysfs_dir,
-						       pv->dev));
+				  DEFAULT_MD_CHUNK_ALIGNMENT)) {
+		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->sysfs_dir, pv->dev);
+		if (temp_pe_align && (default_pe_align % temp_pe_align))
+			pv->pe_align = temp_pe_align;
+	}
 
 	/*
 	 * Align to topology's minimum_io_size or optimal_io_size if present
@@ -94,13 +98,15 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	if (find_config_tree_bool(pv->fmt->cmd,
 				  "devices/data_alignment_detection",
 				  DEFAULT_DATA_ALIGNMENT_DETECTION)) {
-		pv->pe_align = MAX(pv->pe_align,
-				   dev_minimum_io_size(pv->fmt->cmd->sysfs_dir,
-						       pv->dev));
-
-		pv->pe_align = MAX(pv->pe_align,
-				   dev_optimal_io_size(pv->fmt->cmd->sysfs_dir,
-						       pv->dev));
+		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->sysfs_dir,
+						    pv->dev);
+		if (temp_pe_align && (default_pe_align % temp_pe_align))
+			pv->pe_align = temp_pe_align;
+				   
+		temp_pe_align = dev_optimal_io_size(pv->fmt->cmd->sysfs_dir,
+						    pv->dev);
+		if (temp_pe_align && (default_pe_align % temp_pe_align))
+			pv->pe_align = temp_pe_align;
 	}
 
 	log_very_verbose("%s: Setting PE alignment to %lu sectors.",


