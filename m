From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 21 Feb 2013 13:51:32 +0000 (UTC)
Subject: master - pvcreate: fix alignment to incorporate alignment offset if PV has 0 MDAs
Message-ID: <20130221135132.735811C39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=303e86adc8dbbab2fe78412f1b90021e5bdb5bc3
Commit:        303e86adc8dbbab2fe78412f1b90021e5bdb5bc3
Parent:        70f57996b3b9ba126a9cbf69afed79a7d66c793c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 21 14:47:49 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 21 14:51:19 2013 +0100

pvcreate: fix alignment to incorporate alignment offset if PV has 0 MDAs

If zero metadata copies are used, there's no further recalculation of
PV alignment that happens when adding metadata areas to the PV and
which actually calculates the alignment correctly as a matter of fact.
So fix this for "PV without MDA" case as well.

Before this patch:
[1] raw/~ # pvcreate --dataalignment 8m --dataalignmentoffset 4m
--metadatacopies 1 /dev/sda
  Physical volume "/dev/sda" successfully created
[1] raw/~ # pvs -o pv_name,pe_start
  PV         1st PE
  /dev/sda    12.00m
[1] raw/~ # pvcreate --dataalignment 8m --dataalignmentoffset 4m
--metadatacopies 0 /dev/sda
  Physical volume "/dev/sda" successfully created
[1] raw/~ # pvs -o pv_name,pe_start
  PV         1st PE
  /dev/sda     8.00m

After this patch:
[1] raw/~ # pvcreate --dataalignment 8m --dataalignmentoffset 4m
--metadatacopies 1 /dev/sda
  Physical volume "/dev/sda" successfully created
[1] raw/~ # pvs -o pv_name,pe_start
  PV         1st PE
  /dev/sda    12.00m
[1] raw/~ # pvcreate --dataalignment 8m --dataalignmentoffset 4m
--metadatacopies 0 /dev/sda
  Physical volume "/dev/sda" successfully created
[1] raw/~ # pvs -o pv_name,pe_start
  PV         1st PE
  /dev/sda    12.00m

Also, remove a superfluous condition "pv->pe_start < pv->pe_align" in:
  if (pe_start == PV_PE_START_CALC && pv->pe_start < pv->pe_align)
    pv->pe_start = pv->pe_align ...
This part of the condition is not reachable as with the PV_PE_START_CALC,
we always have pv->pe_start set to 0 from the PV struct initialisation
(...the pv->pe_start value is just being calculated).
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |   10 ++++++++--
 lib/metadata/metadata.c       |    2 +-
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 33993e4..82cbfc9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix PV alignment to incorporate alignment offset if the PV has zero MDAs.
   Allow remove/replace of RAID sub-LVs that are composed of error targets.
   Make 'vgreduce --removemissing' able to handle RAID LVs with missing PVs.
   Rename lvm.conf setting 'mirror_region_size' to 'raid_region_size'.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 24fd318..cf15313 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1508,8 +1508,14 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		return 0;
 	}
 
-	if (pe_start == PV_PE_START_CALC && pv->pe_start < pv->pe_align)
-		pv->pe_start = pv->pe_align;
+	if (pv->size < pv->pe_align + pv->pe_align_offset) {
+		log_error("%s: Data alignment must not exceed device size.",
+			  pv_dev_name(pv));
+		return 0;
+	}
+
+	if (pe_start == PV_PE_START_CALC)
+		pv->pe_start = pv->pe_align + pv->pe_align_offset;
 
 	if (extent_size)
 		pv->pe_size = extent_size;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0b774ac..d03b49c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1650,7 +1650,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 		goto bad;
 	}
 
-	if (pv->size < data_alignment) {
+	if (pv->size < data_alignment + data_alignment_offset) {
 		log_error("%s: Data alignment must not exceed device size.",
 			  pv_dev_name(pv));
 		goto bad;


