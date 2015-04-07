From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Apr 2015 12:59:41 +0000 (UTC)
Subject: master - tests: check scsi_debug support opt_blks
Message-ID: <20150407125941.4B4E860A2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8fdca0de7910052594a55bfb7bd3815afe701dad
Commit:        8fdca0de7910052594a55bfb7bd3815afe701dad
Parent:        035276ab83bae4349e06a3158f288fa75e0bdf9c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 7 14:56:16 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 7 14:59:13 2015 +0200

tests: check scsi_debug support opt_blks

Some older kernels (i.e. lenny) do not have such options.
---
 test/lib/aux.sh                |    2 ++
 test/shell/topology-support.sh |    3 +++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0dbb8b9..cc102fe 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -320,6 +320,7 @@ prepare_scsi_debug_dev() {
 	local DEV_SIZE=$1
 	local SCSI_DEBUG_PARAMS=${@:2}
 
+	rm -f debug.log strace.log
 	test ! -f "SCSI_DEBUG_DEV" || return 0
 	test -z "$LOOP"
 	test -n "$DM_DEV_DIR"
@@ -331,6 +332,7 @@ prepare_scsi_debug_dev() {
 	# Create the scsi_debug device and determine the new scsi device's name
 	# NOTE: it will _never_ make sense to pass num_tgts param;
 	# last param wins.. so num_tgts=1 is imposed
+	touch SCSI_DEBUG_DEV
 	modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || skip
 	sleep 2 # allow for async Linux SCSI device registration
 
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 62f2b88..9bded0e 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -96,6 +96,9 @@ vgremove $vg
 
 aux cleanup_scsi_debug_dev
 
+# scsi_debug option opt_blks appeared in Oct 2010
+aux kernel_at_least 2 6 37 || exit 0
+
 # ---------------------------------------------
 # Create "enterprise-class" 512 drive w/ HW raid stripe_size = 768K
 # (logical_block_size=512, physical_block_size=512, alignment_offset=0):


