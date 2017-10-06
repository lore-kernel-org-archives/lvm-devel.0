From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 6 Oct 2017 18:10:25 -0400
Subject: master - man: regenerate
Message-ID: <201710062210.v96MAP26031563@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f005a6e7922d9a95eadfbd433714c80301eba794
Commit:        f005a6e7922d9a95eadfbd433714c80301eba794
Parent:        a994fc5e50d2090dcf209f508696551ce0f5b35a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 6 23:10:02 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 6 23:10:02 2017 +0100

man: regenerate

---
 man/lvconvert.8_pregen |   10 ++++++++--
 man/pvscan.8_pregen    |    7 +++----
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 93a8b27..fb2d869 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -753,10 +753,12 @@ Merge COW snapshot LV into its origin.
 
 Replace failed PVs in a raid or mirror LV. 
 .br
-Repair a thin pool.
+Repair a thin pool. 
+.br
+Repair a cache pool.
 .br
 .P
-\fBlvconvert\fP \fB--repair\fP \fILV\fP\fI_thinpool_mirror_raid\fP
+\fBlvconvert\fP \fB--repair\fP \fILV\fP\fI_thinpool_cache_cachepool_mirror_raid\fP
 .br
 .RS 4
 .ad l
@@ -767,6 +769,10 @@ Repair a thin pool.
 [    \fB--usepolicies\fP ]
 .ad b
 .br
+.ad l
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 4927fcb..ebd155f 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -76,8 +76,7 @@ When event-driven system services detect a new LVM device, the first step
 is to automatically scan and cache the metadata from the device.  This is
 done by pvscan --cache.  A second step is to automatically activate LVs
 that are present on the new device.  This auto-activation is done by the
-same pvscan --cache command when the option '-a|--activate ay' is
-included.
+same pvscan --cache command when the option --activate ay is included.
 
 Auto-activation of VGs or LVs can be enabled/disabled using:
 .br
@@ -92,11 +91,11 @@ When this setting is undefined, all LVs are auto-activated (when lvm is
 fully integrated with the event-driven system services.)
 
 When a VG or LV is not auto-activated, traditional activation using
-vgchange or lvchange -a|--activate is needed.
+vgchange or lvchange --activate is needed.
 .IP \[bu] 2
 pvscan auto-activation can be only done in combination with --cache.
 .IP \[bu] 2
-Auto-activation is designated by the "a" argument in '-a|--activate ay'.
+Auto-activation is designated by the "a" argument in --activate ay.
 This is meant to distinguish system generated commands from explicit user
 commands, although it can be used in any activation command.  Whenever it
 is used, the auto_activation_volume_list is applied.


