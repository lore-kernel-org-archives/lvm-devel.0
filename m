From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 19 Dec 2017 09:32:29 -0500
Subject: master - tests: sleep first
Message-ID: <201712191432.vBJEWTDn018851@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0bf1cc2320cb96cde9be742bed2aa391c998588a
Commit:        0bf1cc2320cb96cde9be742bed2aa391c998588a
Parent:        3a841515af623b86be0628ef6568ff74009ea643
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 13 16:17:56 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 19 15:28:07 2017 +0100

tests: sleep first

Sleep a bit before checking /sys/block dir so the kernel has a moment to
actually put scsi debug device in it...

Some quite old kernels are in troubles with this plain searching grep
without sleep (namely 2.6.32)

modprobe scsi_debug
 <sleep .1>
grep -H scsi_debug /sys/block/*/device/model
modprobe -r scsi_debug
---
 test/lib/aux.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6bc7bd4..fa9a1a2 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -703,10 +703,10 @@ prepare_scsi_debug_dev() {
 	modprobe scsi_debug dev_size_mb="$DEV_SIZE" "$@" num_tgts=1 || skip
 
 	for i in {1..20} ; do
-		DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)"
-		test -b "$DEBUG_DEV" && break
 		sleep .1 # allow for async Linux SCSI device registration
-        done
+		DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/sd*/device/model | cut -f4 -d /)"
+		test -b "$DEBUG_DEV" && break
+	done
 	test -b "$DEBUG_DEV" || return 1 # should not happen
 
 	# Create symlink to scsi_debug device in $DM_DEV_DIR


