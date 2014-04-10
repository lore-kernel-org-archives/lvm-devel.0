From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Apr 2014 13:06:10 +0000 (UTC)
Subject: master - tests: add test for pvcreate --dataalignment --dataalignmentoffset --restorefile compatibility
Message-ID: <20140410130610.EB2A360DD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35721ee134954ec328e8d20e51c13e2e70a438d1
Commit:        35721ee134954ec328e8d20e51c13e2e70a438d1
Parent:        05eb6a167e312679ec8d730f7736023168e77da0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 10 14:46:40 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 10 15:02:35 2014 +0200

tests: add test for pvcreate --dataalignment --dataalignmentoffset --restorefile compatibility

Also, avoid division by zero in the pvcreate's param validation
in case someone supplies "pvcreate --dataalignment 0".
---
 test/shell/pvcreate-operation.sh |   16 ++++++++++++++++
 tools/toollib.c                  |    9 +++++----
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index 4a5c42a..e446b62 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -124,6 +124,22 @@ vgcfgrestore -f $backupfile $vg1
 vgremove -f $vg1
 pvremove -f "$dev1"
 
+# pvcreate --restorefile should handle --dataalignment and --dataalignmentoffset
+# and check it's compatible with pe_start value being restored
+# X * dataalignment + dataalignmentoffset == pe_start
+pvcreate --norestorefile --uuid $uuid1 --dataalignment 600k --dataalignmentoffset 32k "$dev1"
+vgcreate $vg1 "$dev1"
+vgcfgbackup -f $backupfile $vg1
+vgremove -ff $vg1
+pvremove -ff "$dev1"
+# the dataalignment and dataalignmentoffset is ignored here since they're incompatible with pe_start
+pvcreate --restorefile $backupfile --uuid $uuid1 --dataalignment 500k --dataalignmentoffset 10k "$dev1" 2> err
+grep "incompatible with restored pe_start value" err
+# 300k is multiple of 600k so this should pass
+pvcreate --restorefile $backupfile --uui $uuid1 --dataalignment 300k --dataalignmentoffset 32k "$dev1" 2> err
+not grep "incompatible with restored pe_start value" err
+rm -f $backupfile
+
 # pvcreate rejects non-existent uuid given with restorefile
 not pvcreate --uuid $uuid1 --restorefile $backupfile "$dev1"
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 052c141..add20e3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1593,10 +1593,11 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 
 	if ((pp->data_alignment + pp->data_alignment_offset) &&
 	    (pp->rp.pe_start != PV_PE_START_CALC)) {
-		if ((pp->rp.pe_start % pp->data_alignment) != pp->data_alignment_offset) {
-			log_warn("WARNING: Ignoring data alignment %" PRIu64
-				 " incompatible with restored pe_start value %" PRIu64").",
-				 pp->data_alignment + pp->data_alignment_offset, pp->rp.pe_start);
+		if ((pp->data_alignment ? pp->rp.pe_start % pp->data_alignment : pp->rp.pe_start) != pp->data_alignment_offset) {
+			log_warn("WARNING: Ignoring data alignment %s"
+				 " incompatible with restored pe_start value %s)",
+				 display_size(cmd, pp->data_alignment + pp->data_alignment_offset),
+				 display_size(cmd, pp->rp.pe_start));
 			pp->data_alignment = 0;
 			pp->data_alignment_offset = 0;
 		}


