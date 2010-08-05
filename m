From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 5 Aug 2010 15:10:01 -0400
Subject: [RFC PATCH] change default alignment of pe_start to 1MB
Message-ID: <20100805191001.GA27237@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The new standard in the storage industry is to default alignment of data
areas to 1MB.  fdisk, parted, and mdadm have all been updated to this
default.

Update LVM to align the PV's data area start (pe_start) to 1MB.  This
provides a more useful default than the previous default of 64K (which
generally ended up being a 192K pe_start once the first metadata area
was created).

Having recently boasted about the new 1MB default in the Linux storage
stack I was soon faced with the harsh reality that LVM was a weak link
(on legacy hardware that doesn't export I/O topology limits).

This meant that an 8 disk HW raid0 array (with 64K chunk_size) ended up
having a PV pe_start that was not aligned on a full-stripe boundary.
The array would've been configured optimally "out of the box" had LVM
used a default alignment of 1MB.

Before this patch:
# pvs -o name,vg_mda_size,pe_start
  PV         VMdaSize  1st PE 
  /dev/sdd     188.00k 192.00k

After this patch:
# pvs -o name,vg_mda_size,pe_start
  PV         VMdaSize  1st PE 
  /dev/sdd    1020.00k   1.00m

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 doc/example.conf.in     |    2 +-
 lib/metadata/metadata.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

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
index d7edf54..887c8bc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -70,7 +70,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	if (data_alignment)
 		pv->pe_align = data_alignment;
 	else
-		pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
+		pv->pe_align = MAX(1048576UL, lvm_getpagesize()) >> SECTOR_SHIFT;
 
 	if (!pv->dev)
 		goto out;


