From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  3 May 2022 17:11:37 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20220503171137.3A1993954C67@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff6022d400430df2f51160ce9eec4010ac55696c
Commit:        ff6022d400430df2f51160ce9eec4010ac55696c
Parent:        5e060b8fa71dcf7ad2ff2daca8dbfa009f691852
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 2 13:16:25 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 3 19:09:52 2022 +0200

make: generate

---
 man/lvchange.8_pregen        | 31 ++++++++++++++++++++++++-------
 man/lvconvert.8_pregen       | 33 ++++++++++++++++++++++++++-------
 man/lvcreate.8_pregen        | 35 ++++++++++++++++++++++++++++-------
 man/lvdisplay.8_pregen       |  3 ++-
 man/lvextend.8_pregen        |  3 ++-
 man/lvm-fullreport.8_pregen  |  3 ++-
 man/lvm-lvpoll.8_pregen      |  3 ++-
 man/lvmconfig.8_pregen       |  3 ++-
 man/lvmdevices.8_pregen      | 14 ++++++++++----
 man/lvmdiskscan.8_pregen     |  3 ++-
 man/lvreduce.8_pregen        |  3 ++-
 man/lvremove.8_pregen        |  3 ++-
 man/lvrename.8_pregen        |  3 ++-
 man/lvresize.8_pregen        |  3 ++-
 man/lvs.8_pregen             |  3 ++-
 man/lvscan.8_pregen          |  3 ++-
 man/pvchange.8_pregen        |  3 ++-
 man/pvck.8_pregen            |  3 ++-
 man/pvcreate.8_pregen        |  3 ++-
 man/pvdisplay.8_pregen       |  3 ++-
 man/pvmove.8_pregen          |  3 ++-
 man/pvremove.8_pregen        |  3 ++-
 man/pvresize.8_pregen        |  3 ++-
 man/pvs.8_pregen             |  3 ++-
 man/pvscan.8_pregen          |  3 ++-
 man/vgcfgbackup.8_pregen     |  3 ++-
 man/vgcfgrestore.8_pregen    |  3 ++-
 man/vgchange.8_pregen        |  3 ++-
 man/vgck.8_pregen            |  3 ++-
 man/vgconvert.8_pregen       |  3 ++-
 man/vgcreate.8_pregen        |  3 ++-
 man/vgdisplay.8_pregen       |  3 ++-
 man/vgexport.8_pregen        |  3 ++-
 man/vgextend.8_pregen        |  3 ++-
 man/vgimport.8_pregen        |  3 ++-
 man/vgimportclone.8_pregen   |  3 ++-
 man/vgimportdevices.8_pregen |  3 ++-
 man/vgmerge.8_pregen         |  3 ++-
 man/vgmknodes.8_pregen       |  3 ++-
 man/vgreduce.8_pregen        |  3 ++-
 man/vgremove.8_pregen        |  3 ++-
 man/vgrename.8_pregen        |  3 ++-
 man/vgs.8_pregen             |  3 ++-
 man/vgscan.8_pregen          |  3 ++-
 man/vgsplit.8_pregen         |  3 ++-
 45 files changed, 170 insertions(+), 66 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index b559c89c9..babeb1b29 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -126,6 +126,8 @@ lvchange \(em Change the attributes of logical volume(s)
     \fB--sysinit\fP
 .br
  \fB-t\fP|\fB--test\fP
+.br
+    \fB--vdosettings\fP \fIString\fP
 .br
  \fB-v\fP|\fB--verbose\fP
 .br
@@ -202,6 +204,8 @@ required, after which the others are optional.
      \fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
      \fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT]
+.br
+     \fB--vdosettings\fP \fIString\fP
 .br
      \fB--\fP[\fBraid\fP]\fBwritebehind\fP \fINumber\fP
 .br
@@ -545,12 +549,13 @@ See \fBlvmcache\fP(7) for more information.
 .HP
 \fB--cachesettings\fP \fIString\fP
 .br
-Specifies tunable values for a cache LV in "Key = Value" form.
-Repeat this option to specify multiple values.
-(The default values should usually be adequate.)
-The special string value \fBdefault\fP switches
-settings back to their default kernel values and removes
-them from the list of settings stored in LVM metadata.
+Specifies tunable kernel options for dm-cache or dm-writecache LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --cachesettings for each option being set.
+These settings override the default kernel behaviors which are
+usually adequate. To remove cachesettings and revert to the default
+kernel behaviors, use --cachesettings 'default' for dm-cache or
+an empty string --cachesettings '' for dm-writecache.
 See \fBlvmcache\fP(7) for more information.
 .
 .HP
@@ -752,7 +757,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
@@ -927,6 +933,17 @@ error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .
 .HP
+\fB--vdosettings\fP \fIString\fP
+.br
+Specifies tunable VDO options for VDO LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --vdosettings for each option being set.
+These settings override the default VDO behaviors.
+To remove vdosettings and revert to the default
+VDO behaviors, use --vdosettings 'default'.
+See \fBlvmvdo\fP(7) for more information.
+.
+.HP
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 679519303..156ae00ce 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -155,6 +155,8 @@ lvconvert \(em Change logical volume layout
     \fB--usepolicies\fP
 .br
     \fB--vdopool\fP \fILV\fP
+.br
+    \fB--vdosettings\fP \fIString\fP
 .br
  \fB-v\fP|\fB--verbose\fP
 .br
@@ -742,6 +744,8 @@ Convert LV to type vdopool.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -1064,12 +1068,13 @@ The name of a cache pool.
 .HP
 \fB--cachesettings\fP \fIString\fP
 .br
-Specifies tunable values for a cache LV in "Key = Value" form.
-Repeat this option to specify multiple values.
-(The default values should usually be adequate.)
-The special string value \fBdefault\fP switches
-settings back to their default kernel values and removes
-them from the list of settings stored in LVM metadata.
+Specifies tunable kernel options for dm-cache or dm-writecache LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --cachesettings for each option being set.
+These settings override the default kernel behaviors which are
+usually adequate. To remove cachesettings and revert to the default
+kernel behaviors, use --cachesettings 'default' for dm-cache or
+an empty string --cachesettings '' for dm-writecache.
 See \fBlvmcache\fP(7) for more information.
 .
 .HP
@@ -1303,7 +1308,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
@@ -1535,6 +1541,17 @@ The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
 .
 .HP
+\fB--vdosettings\fP \fIString\fP
+.br
+Specifies tunable VDO options for VDO LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --vdosettings for each option being set.
+These settings override the default VDO behaviors.
+To remove vdosettings and revert to the default
+VDO behaviors, use --vdosettings 'default'.
+See \fBlvmvdo\fP(7) for more information.
+.
+.HP
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
@@ -1808,6 +1825,8 @@ Convert LV to type vdopool.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 2cccbbe56..a454d175f 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -157,6 +157,8 @@ lvcreate \(em Create a logical volume
     \fB--vdo\fP
 .br
     \fB--vdopool\fP \fILV\fP
+.br
+    \fB--vdosettings\fP \fIString\fP
 .br
  \fB-v\fP|\fB--verbose\fP
 .br
@@ -537,6 +539,8 @@ Create a LV that returns VDO when used.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -927,12 +931,13 @@ The name of a cache pool.
 .HP
 \fB--cachesettings\fP \fIString\fP
 .br
-Specifies tunable values for a cache LV in "Key = Value" form.
-Repeat this option to specify multiple values.
-(The default values should usually be adequate.)
-The special string value \fBdefault\fP switches
-settings back to their default kernel values and removes
-them from the list of settings stored in LVM metadata.
+Specifies tunable kernel options for dm-cache or dm-writecache LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --cachesettings for each option being set.
+These settings override the default kernel behaviors which are
+usually adequate. To remove cachesettings and revert to the default
+kernel behaviors, use --cachesettings 'default' for dm-cache or
+an empty string --cachesettings '' for dm-writecache.
 See \fBlvmcache\fP(7) for more information.
 .
 .HP
@@ -1190,7 +1195,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosync\fP
@@ -1438,6 +1444,17 @@ The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
 .
 .HP
+\fB--vdosettings\fP \fIString\fP
+.br
+Specifies tunable VDO options for VDO LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --vdosettings for each option being set.
+These settings override the default VDO behaviors.
+To remove vdosettings and revert to the default
+VDO behaviors, use --vdosettings 'default'.
+See \fBlvmvdo\fP(7) for more information.
+.
+.HP
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
@@ -1966,6 +1983,8 @@ Create a VDO LV with VDO pool.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -1996,6 +2015,8 @@ Create a VDO LV with VDO pool.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 04aab4c09..03235ef1a 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -278,7 +278,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosuffix\fP
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index be6992e94..8bc2c2523 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -423,7 +423,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosync\fP
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 02b38ef40..115f50d4a 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -254,7 +254,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosuffix\fP
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 7f45f6eb3..43696c1b7 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -181,7 +181,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 51946e1ec..bab5d6056 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -261,7 +261,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/lvmdevices.8_pregen b/man/lvmdevices.8_pregen
index a2391a62b..90d3af455 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -24,7 +24,7 @@ lvmdevices \(em Manage the devices file
 .br
  \fB-d\fP|\fB--debug\fP
 .br
-    \fB--deldev\fP \fIPV\fP
+    \fB--deldev\fP \fIString\fP
 .br
     \fB--delpvid\fP \fIString\fP
 .br
@@ -152,6 +152,7 @@ is used for dm crypt devices, reported by sysfs.
 .IP \[bu] 2
 .B md_uuid
 is used for md devices, reported by sysfs.
+.IP \[bu] 2
 .B lvmlv_uuid
 is used if a PV is placed on top of an lvm LV, reported by sysfs.
 .IP \[bu] 2
@@ -226,10 +227,12 @@ Add a device to the devices file.
 Remove a device from the devices file.
 .br
 .P
-\fBlvmdevices\fP \fB--deldev\fP \fIPV\fP
+\fBlvmdevices\fP \fB--deldev\fP \fIString\fP|\fIPV\fP
 .br
 .RS 4
 .ad l
+[    \fB--deviceidtype\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -346,9 +349,11 @@ Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .
 .HP
-\fB--deldev\fP \fIPV\fP
+\fB--deldev\fP \fIString\fP
 .br
 Remove a device from the devices file.
+When used alone, --deldev specifies a device name.
+When used with --deviceidtype, --deldev specifies a device id.
 .
 .HP
 \fB--delpvid\fP \fIString\fP
@@ -420,7 +425,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 7fd3d941d..0d5fdc741 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -162,7 +162,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index ea960eb53..6c55ae158 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -220,7 +220,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 2bd7997a3..5b471f0e5 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -204,7 +204,8 @@ metadata/record_lvs_history is enabled.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index d41a4c241..9624611d1 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -175,7 +175,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index f3ea2536c..bacad4f46 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -376,7 +376,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosync\fP
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 2b2c5f193..8540816d3 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -264,7 +264,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosuffix\fP
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index f459ab35b..20a51ae99 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -180,7 +180,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 4add9ca69..1ace1b6b4 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -248,7 +248,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 88200f21e..3f60ff818 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -435,7 +435,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index a74a5ec2a..043f067f7 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -319,7 +319,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--norestorefile\fP
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 2f26a8727..4c681c955 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -266,7 +266,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosuffix\fP
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index 0f70497a2..ea300bb9d 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -271,7 +271,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 3d4a86c09..ce01d3398 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -164,7 +164,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 87d87c8ce..85078e18d 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -153,7 +153,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 32c28e4d1..e9f981a9e 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -254,7 +254,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosuffix\fP
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 4622e145e..00743a7d4 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -469,7 +469,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 5e658093a..0f051b75e 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -197,7 +197,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 695e05582..67e8ae8e8 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -291,7 +291,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 9dbad3faa..1dafeafd0 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -694,7 +694,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index a8fa33f4b..76ef1a284 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -169,7 +169,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 4d54c2b27..8fe27ca2e 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -206,7 +206,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 9bb8d3868..7b8b81885 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -313,7 +313,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 0a12b3c39..3fd7e55c2 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -258,7 +258,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosuffix\fP
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index a87058946..3709434bb 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -194,7 +194,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 2b2650527..3ea40988a 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -237,7 +237,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 5cd8fab84..0eb9d627d 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -189,7 +189,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index bf0af5841..151fa9282 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -179,7 +179,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgimportdevices.8_pregen b/man/vgimportdevices.8_pregen
index 5897e29ad..3f09499e0 100644
--- a/man/vgimportdevices.8_pregen
+++ b/man/vgimportdevices.8_pregen
@@ -193,7 +193,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index a36e0c7bd..298e30868 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -167,7 +167,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 0a03e1582..f57440ef3 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -169,7 +169,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index f3178a618..759160a6c 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -265,7 +265,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index 779c0f13e..fa601b8cf 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -170,7 +170,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--noudevsync\fP
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index d3e776ca4..615559bb0 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -194,7 +194,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--profile\fP \fIString\fP
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index ee5083a93..7c4a06d6d 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -251,7 +251,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--nosuffix\fP
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 824e7f673..c0a3de185 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -168,7 +168,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--notifydbus\fP
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 065c8b52a..fb217beed 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -255,7 +255,8 @@ perform standard hint file invalidation where appropriate.
 .HP
 \fB--nolocking\fP
 .br
-Disable locking.
+Disable locking. Use with caution, concurrent commands may produce
+incorrect results.
 .
 .HP
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP

