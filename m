From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  4 Apr 2014 14:52:37 +0000 (UTC)
Subject: master - man: lvmthin clean up lvm.conf references
Message-ID: <20140404145237.37025608F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fd5c67f329159cfae29e2d0fe98fe2fbb6d9a8f
Commit:        2fd5c67f329159cfae29e2d0fe98fe2fbb6d9a8f
Parent:        a7c930b18da8f8179312e395c49f72080edd687e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 4 09:50:17 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 4 09:51:56 2014 -0500

man: lvmthin clean up lvm.conf references

---
 man/lvmthin.7.in |   67 ++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 50 insertions(+), 17 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 56bc93e..55b1562 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -274,8 +274,10 @@ Example
 # lvconvert --thinpool vg/pool0 --poolmetadata vg/pool0meta
 .fi
 
-See lvm.conf thin_pool_metadata_require_separate_pvs to set
-default PV usage for thin pool creation.
+.BR lvm.conf (5)
+.B thin_pool_metadata_require_separate_pvs
+.br
+controls the default PV usage for thin pool creation.
 
 
 .SS Tolerate device failures using raid
@@ -343,10 +345,16 @@ running fsck on a file system.
 When a thin pool LV is activated, lvm runs the thin_check command
 to check the correctness of the metadata on the pool metadata LV.
 
-To disable the thin_check step, set lvm.conf thin_check_executable to
-an empty string ("").  This is not recommended.
+.BR lvm.conf (5)
+.B thin_check_executable
+.br
+can be set to an empty string ("") to disable the thin_check step.
+This is not recommended.
 
-To set options for the thin_check command, set lvm.conf thin_check_options.
+.BR lvm.conf (5)
+.B thin_check_options
+.br
+controls the command options used for the thin_check command.
 
 If the thin_check command finds a problem with the metadata,
 the thin pool LV is not activated, and the thin pool metadata should
@@ -387,9 +395,6 @@ containing new metadata:
 lvconvert --thinpool VG/ThinPoolLV --poolmetadata VG/NewThinMetaLV
 .fi
 
-The path to thin_check, thin_dump and thin_repair commands
-can be set in lvm.conf.
-
 
 .SS Automatic pool metadata LV
 
@@ -460,8 +465,10 @@ Command to remove the activation skip flag from a snapshot LV:
 lvchange -kn VG/SnapLV
 .fi
 
-See lvm.conf auto_set_activation_skip to set default usage of
-activation skip.
+.BR lvm.conf (5)
+.B auto_set_activation_skip
+.br
+controls the default activation skip setting used by lvcreate.
 
 
 .SS Removing thin pool LVs, thin LVs and snapshots
@@ -630,14 +637,18 @@ of an existing thin pool LV:
 lvchange --monitor {y|n} VG/ThinPoolLV
 .fi
  
-The lvm.conf thin_pool_autoextend_threshold and thin_pool_autoextend_percent
-options define the autoextend behavior.
+.BR lvm.conf (5)
+.B thin_pool_autoextend_threshold thin_pool_autoextend_percent
+.br
+control the default autoextend behavior.
 
-thin_pool_autoextend_threshold is a percentage value that defines when
+thin_pool_autoextend_threshold
+is a percentage value that defines when
 the thin pool LV should be extended.  Setting this to 100 disables
 automatic extention.  The minimum value is 50.
 
-thin_pool_autoextend_percent defines how much extra data space should
+thin_pool_autoextend_percent
+defines how much extra data space should
 be added to the thin pool, in percent of its current size.
 
 Warnings are emitted through syslog when the use of a pool reaches 80%,
@@ -747,7 +758,10 @@ blocks are not zeroed.
 
 Provisioning of large zeroed chunks impacts performance.
 
-See lvm.conf thin_pool_zero to set default zeroing mode.
+.BR lvm.conf (5)
+.B thin_pool_zero
+.br
+controls the default zeroing mode used when creating a thin pool.
 
 
 .SS Discard
@@ -790,7 +804,10 @@ pool0 passdown
 # lvchange --discards ignore vg/pool0
 .fi
 
-See lvm.conf thin_pool_discards to set the default discards mode.
+.BR lvm.conf (5)
+.B thin_pool_discards
+.br
+controls the default discards mode used when creating a thin pool.
 
 
 .SS Chunk size
@@ -815,7 +832,10 @@ Example
 pool0 64.00k
 .fi
 
-See lvm.conf thin_pool_chunk_size to set the default chunk size.
+.BR lvm.conf (5)
+.B thin_pool_chunk_size
+.br
+controls the default chunk size used when creating a thin pool.
 
 
 .SS Size of pool metadata LV
@@ -956,3 +976,16 @@ pool0           vg          twi-a-tz--   8.00m
 thin1           vg          Vwi-a-tz--   2.00g pool0
 .fi
 
+.SH SEE ALSO
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvcreate (8),
+.BR lvconvert (8),
+.BR lvchange (8),
+.BR lvextend (8),
+.BR lvremove (8),
+.BR lvs (8),
+.BR thin_dump (8),
+.BR thin_repair (8)
+.BR thin_restore (8)
+


