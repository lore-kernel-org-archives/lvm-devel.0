From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 27 May 2015 20:55:00 +0000 (UTC)
Subject: master - man: lvmthin chunk and metadata sizes
Message-ID: <20150527205500.DF3EB60552@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3225f8d17596b79b76ed9da5291843d02a2aa7b6
Commit:        3225f8d17596b79b76ed9da5291843d02a2aa7b6
Parent:        778b66a7199b5fe05d59df55bd23e681759c2bbe
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 27 15:53:01 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 27 15:53:01 2015 -0500

man: lvmthin chunk and metadata sizes

Clear some stale information, and give a suggestion to use
a metadata size of 1GiB.
---
 man/lvmthin.7.in |   54 ++++++++++++++++++++++++++++++------------------------
 1 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 79ca40a..eb791f0 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -907,12 +907,12 @@ autoextend the LV by this much additional space.
 
 To see the default values of these settings, run:
 
-.B lvmconfig --type default --withcomment
+.B lvmconfig \-\-type default \-\-withcomment
 .RS
 .B activation/thin_pool_autoextend_threshold
 .RE
 
-.B lvmconfig --type default --withcomment
+.B lvmconfig \-\-type default \-\-withcomment
 .RS
 .B activation/thin_pool_autoextend_percent
 .RE
@@ -973,7 +973,7 @@ file with the profile also needs to be moved.
 .IP \[bu] 2
 Only certain settings can be used in a VG or LV profile, see:
 .br
-.B lvmconfig --type profilable-metadata.
+.B lvmconfig \-\-type profilable-metadata.
 
 .IP \[bu] 2
 An LV without a profile of its own will inherit the VG profile.
@@ -986,9 +986,9 @@ Remove a profile from an LV using the command:
 .IP \[bu] 2
 Commands can also have profiles applied to them.  The settings that can be
 applied to a command are different than the settings that can be applied
-to a VG or LV.  See lvmconfig --type profilable-command.  To apply a
+to a VG or LV.  See lvmconfig \-\-type profilable\-command.  To apply a
 profile to a command, write a profile, save it in the profile directory,
-and run the command using the option: --commandprofile ProfileName.
+and run the command using the option: \-\-commandprofile ProfileName.
 
 
 .SS Zeroing
@@ -1076,14 +1076,13 @@ controls the default discards mode used when creating a thin pool.
 
 \&
 
-The size of data blocks managed by a thin pool can be specified with
-the \-\-chunksize option when the thin pool LV is created.  The default
-unit is kilobytes and the default value is 64KiB.  The value must be a
-power of two between 4KiB and 1GiB.
+The size of data blocks managed by a thin pool can be specified with the
+\-\-chunksize option when the thin pool LV is created.  The default unit
+is KiB. The value must be a multiple of 64KiB between 64KiB and 1GiB.
 
-When a thin pool is used primarily for the thin provisioning feature,
-a larger value is optimal.  To optimize for a lot of snapshotting,
-a smaller value reduces copying time and consumes less space.
+When a thin pool is used primarily for the thin provisioning feature, a
+larger value is optimal.  To optimize for many snapshots, a smaller value
+reduces copying time and consumes less space.
 
 Command to display the thin pool LV chunk size:
 .br
@@ -1101,25 +1100,32 @@ Command to display the thin pool LV chunk size:
 .br
 controls the default chunk size used when creating a thin pool.
 
+The default value is shown by:
+.br
+.B lvmconfig \-\-type default allocation/thin_pool_chunk_size
+
 
 .SS Size of pool metadata LV
 
 \&
 
-The amount of thin metadata depends on how many blocks are shared
-between thin LVs (i.e. through snapshots).  A thin pool with many
-snapshots may need a larger metadata LV.
+The amount of thin metadata depends on how many blocks are shared between
+thin LVs (i.e. through snapshots).  A thin pool with many snapshots may
+need a larger metadata LV.  Thin pool metadata LV sizes can be from 2MiB
+to 16GiB.
 
-The range of supported metadata LV sizes is 2MiB to 16GiB.
-.br
-The default size is estimated with the formula:
-.br
-ThinPoolLVSize / ThinPoolLVChunkSize * 64b.
+When using lvcreate to create what will become a thin metadata LV, the
+size is specified with the \-L|\-\-size option.
+
+When an LVM command automatically creates a thin metadata LV, the size is
+specified with the \-\-poolmetadatasize option.  When this option is not
+given, LVM automatically chooses a size based on the data size and chunk
+size.
 
-When creating a thin metadata LV explicitly, the size is specified
-in the lvcreate command.  When a command automatically creates a
-thin metadata LV, the \-\-poolmetadatasize option can be used specify
-a non-default size.  The default unit is megabytes.
+It can be hard to predict the amount of metadata space that will be
+needed, so it is recommended to start with a size of 1GiB which should be
+enough for all practical purposes.  A thin pool metadata LV can later be
+manually or automatically extended if needed.
 
 
 .SS Create a thin snapshot of an external, read only LV


