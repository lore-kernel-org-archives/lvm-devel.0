From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 23 Mar 2017 20:05:59 -0400
Subject: master - man: escape all double '-'
Message-ID: <201703240005.v2O05xRn003787@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a29bb6a14b5e920092495fb9a1623e527d22daac
Commit:        a29bb6a14b5e920092495fb9a1623e527d22daac
Parent:        2eaca7ab63345594ccfd7133ddf92729b7e7691c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 01:03:58 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 01:03:58 2017 +0100

man: escape all double '-'

---
 man/Makefile.in             |    6 +-
 man/dmeventd.8_main         |    4 +-
 man/dmstats.8_main          |    2 +-
 man/lvchange.8_pregen       |  364 +++++++++---------
 man/lvconvert.8_end         |    6 +-
 man/lvconvert.8_pregen      |  558 +++++++++++++-------------
 man/lvcreate.8_des          |    6 +-
 man/lvcreate.8_pregen       |  934 +++++++++++++++++++++---------------------
 man/lvdisplay.8_pregen      |  166 ++++----
 man/lvextend.8_des          |    4 +-
 man/lvextend.8_pregen       |  202 +++++-----
 man/lvm-config.8_pregen     |  140 ++++----
 man/lvm-dumpconfig.8_pregen |  140 ++++----
 man/lvm-fullreport.8_pregen |  168 ++++----
 man/lvm-lvpoll.8_end        |   12 +-
 man/lvm-lvpoll.8_pregen     |   86 ++--
 man/lvm.8_main              |    6 +-
 man/lvm.conf.5_main         |    4 +-
 man/lvmcache.7_main         |   42 +-
 man/lvmconfig.8_pregen      |  140 ++++----
 man/lvmdiskscan.8_pregen    |   62 ++--
 man/lvmlockctl.8_main       |    2 +-
 man/lvmlockd.8_main         |    6 +-
 man/lvmraid.7_main          |  338 ++++++++--------
 man/lvmreport.7_main        |  202 +++++-----
 man/lvmsystemid.7_main      |   18 +-
 man/lvmthin.7_main          |  128 +++---
 man/lvreduce.8_des          |    4 +-
 man/lvreduce.8_pregen       |   96 +++---
 man/lvremove.8_pregen       |   84 ++--
 man/lvrename.8_pregen       |   66 ++--
 man/lvresize.8_des          |    4 +-
 man/lvresize.8_pregen       |  180 +++++-----
 man/lvs.8_pregen            |  176 ++++----
 man/lvscan.8_pregen         |   82 ++--
 man/pvchange.8_pregen       |  116 +++---
 man/pvck.8_pregen           |   58 ++--
 man/pvcreate.8_pregen       |  128 +++---
 man/pvdisplay.8_pregen      |  156 ++++----
 man/pvmove.8_pregen         |   92 +++---
 man/pvremove.8_pregen       |   62 ++--
 man/pvresize.8_pregen       |   62 ++--
 man/pvs.8_pregen            |  172 ++++----
 man/pvscan.8_des            |   10 +-
 man/pvscan.8_pregen         |  108 +++---
 man/vgcfgbackup.8_pregen    |   78 ++--
 man/vgcfgrestore.8_pregen   |  106 +++---
 man/vgchange.8_pregen       |  328 ++++++++--------
 man/vgck.8_pregen           |   58 ++--
 man/vgconvert.8_pregen      |   86 ++--
 man/vgcreate.8_pregen       |  152 ++++----
 man/vgdisplay.8_pregen      |  156 ++++----
 man/vgexport.8_pregen       |   72 ++--
 man/vgextend.8_pregen       |  106 +++---
 man/vgimport.8_pregen       |   76 ++--
 man/vgimportclone.8_pregen  |   62 ++--
 man/vgmerge.8_pregen        |   62 ++--
 man/vgmknodes.8_pregen      |   66 ++--
 man/vgreduce.8_pregen       |  116 +++---
 man/vgremove.8_pregen       |   76 ++--
 man/vgrename.8_pregen       |   66 ++--
 man/vgs.8_pregen            |  168 ++++----
 man/vgscan.8_pregen         |   78 ++--
 man/vgsplit.8_pregen        |   90 ++--
 64 files changed, 3702 insertions(+), 3702 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 57d9627..3266f1a 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -143,7 +143,7 @@ $(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS): Make
 
 # Test whether or not the man page generator works
 $(TESTMAN): $(MANGENERATOR) Makefile
-	- $(MANGENERATOR) --primary lvmconfig > $@
+	- $(MANGENERATOR) \-\-primary lvmconfig > $@
 
 SEE_ALSO=$(srcdir)/see_also.end
 
@@ -162,8 +162,8 @@ SEE_ALSO=$(srcdir)/see_also.end
 		cat $(srcdir)/$(@:%.8_gen=%.8_pregen) ; \
 	    else \
 		MANCMD=$(basename $@) && \
-		$(MANGENERATOR) --primary $$MANCMD $< && \
-		$(MANGENERATOR) --secondary $$MANCMD && \
+		$(MANGENERATOR) \-\-primary $$MANCMD $< && \
+		$(MANGENERATOR) \-\-secondary $$MANCMD && \
 		cat $(srcdir)/$(basename $@).8_end && \
 		cat $(SEE_ALSO) ; \
 	    fi \
diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index 057f756..c3b6954 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -106,7 +106,7 @@ of the thin pool is filled. See
 When a thin pool fills over 50% (data or metadata) thin plugin calls
 configured \fIdmeventd/thin_command\fP with every 5% increase.
 With default setting it calls internal
-\fBlvm lvextend --use-policies\fP to resize thin pool
+\fBlvm lvextend \-\-use-policies\fP to resize thin pool
 when it's been filled above configured threshold
 \fIactivation/thin_pool_autoextend_threshold\fP.
 If the command fails, dmeventd thin plugin will keep
@@ -116,7 +116,7 @@ User may also configure external command to support more advanced
 maintenance operations of a thin pool.
 Such external command can e.g. remove some unneeded snapshots,
 use \fBfstrim\fP(8) to free recover space in a thin pool,
-but also can use \fBlvextend --use-policies\fP if other actions
+but also can use \fBlvextend \-\-use-policies\fP if other actions
 have not released enough space.
 Command is executed with environmental variable
 \fBLVM_RUN_BY_DMEVENTD=1\fP so any lvm2 command executed
diff --git a/man/dmstats.8_main b/man/dmstats.8_main
index 682f01d..e7e8203 100644
--- a/man/dmstats.8_main
+++ b/man/dmstats.8_main
@@ -1247,7 +1247,7 @@ Create regions mapping each file in the directory images/ and place
 them into separate groups, each named after the corresponding file
 .br
 #
-.B dmstats create --filemap images/*
+.B dmstats create \-\-filemap images/*
 .br
 images/vm1.qcow2: Created new group with 87 region(s) as group ID 0.
 .br
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 5d63f47..726a89f 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -9,215 +9,215 @@ lvchange \- Change the attributes of logical volume(s)
 .br
 .P
 .ad l
- \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+ \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .ad b
 .br
 .ad l
-    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
+    \fB\-\-activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .ad b
 .br
 .ad l
-    \fB--addtag\fP \fITag\fP
+    \fB\-\-addtag\fP \fITag\fP
 .ad b
 .br
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
 .br
 .ad l
- \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
+    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .ad b
 .br
 .ad l
-    \fB--cachepolicy\fP \fIString\fP
+    \fB\-\-cachepolicy\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--cachesettings\fP \fIString\fP
+    \fB\-\-cachesettings\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--commandprofile\fP \fIString\fP
+    \fB\-\-commandprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--config\fP \fIString\fP
+    \fB\-\-config\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
+ \fB-C\fP|\fB\-\-contiguous\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-d\fP|\fB--debug\fP
+ \fB-d\fP|\fB\-\-debug\fP
 .ad b
 .br
 .ad l
-    \fB--deltag\fP \fITag\fP
+    \fB\-\-deltag\fP \fITag\fP
 .ad b
 .br
 .ad l
-    \fB--detachprofile\fP
+    \fB\-\-detachprofile\fP
 .ad b
 .br
 .ad l
-    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
+    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .ad b
 .br
 .ad l
-    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
+    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-f\fP|\fB--force\fP
+ \fB-f\fP|\fB\-\-force\fP
 .ad b
 .br
 .ad l
- \fB-h\fP|\fB--help\fP
+ \fB-h\fP|\fB\-\-help\fP
 .ad b
 .br
 .ad l
- \fB-K\fP|\fB--ignoreactivationskip\fP
+ \fB-K\fP|\fB\-\-ignoreactivationskip\fP
 .ad b
 .br
 .ad l
-    \fB--ignorelockingfailure\fP
+    \fB\-\-ignorelockingfailure\fP
 .ad b
 .br
 .ad l
-    \fB--ignoremonitoring\fP
+    \fB\-\-ignoremonitoring\fP
 .ad b
 .br
 .ad l
-    \fB--ignoreskippedcluster\fP
+    \fB\-\-ignoreskippedcluster\fP
 .ad b
 .br
 .ad l
-    \fB--longhelp\fP
+    \fB\-\-longhelp\fP
 .ad b
 .br
 .ad l
- \fB-j\fP|\fB--major\fP \fINumber\fP
+ \fB-j\fP|\fB\-\-major\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
+    \fB\-\-[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
-    \fB--metadataprofile\fP \fIString\fP
+    \fB\-\-metadataprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--minor\fP \fINumber\fP
+    \fB\-\-minor\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
+    \fB\-\-[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
-    \fB--monitor\fP \fBy\fP|\fBn\fP
+    \fB\-\-monitor\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--noudevsync\fP
+    \fB\-\-noudevsync\fP
 .ad b
 .br
 .ad l
- \fB-P\fP|\fB--partial\fP
+ \fB-P\fP|\fB\-\-partial\fP
 .ad b
 .br
 .ad l
- \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
+ \fB-p\fP|\fB\-\-permission\fP \fBrw\fP|\fBr\fP
 .ad b
 .br
 .ad l
- \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
+ \fB-M\fP|\fB\-\-persistent\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--poll\fP \fBy\fP|\fBn\fP
+    \fB\-\-poll\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--profile\fP \fIString\fP
+    \fB\-\-profile\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-q\fP|\fB--quiet\fP
+ \fB-q\fP|\fB\-\-quiet\fP
 .ad b
 .br
 .ad l
- \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
+ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--rebuild\fP \fIPV\fP
+    \fB\-\-rebuild\fP \fIPV\fP
 .ad b
 .br
 .ad l
-    \fB--refresh\fP
+    \fB\-\-refresh\fP
 .ad b
 .br
 .ad l
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .ad b
 .br
 .ad l
-    \fB--resync\fP
+    \fB\-\-resync\fP
 .ad b
 .br
 .ad l
- \fB-S\fP|\fB--select\fP \fIString\fP
+ \fB-S\fP|\fB\-\-select\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
+ \fB-k\fP|\fB\-\-setactivationskip\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
+    \fB\-\-[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
 .ad b
 .br
 .ad l
-    \fB--sysinit\fP
+    \fB\-\-sysinit\fP
 .ad b
 .br
 .ad l
- \fB-t\fP|\fB--test\fP
+ \fB-t\fP|\fB\-\-test\fP
 .ad b
 .br
 .ad l
- \fB-v\fP|\fB--verbose\fP
+ \fB-v\fP|\fB\-\-verbose\fP
 .ad b
 .br
 .ad l
-    \fB--version\fP
+    \fB\-\-version\fP
 .ad b
 .br
 .ad l
-    \fB--[raid]writebehind\fP \fINumber\fP
+    \fB\-\-[raid]writebehind\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
+    \fB\-\-[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
 .ad b
 .br
 .ad l
- \fB-y\fP|\fB--yes\fP
+ \fB-y\fP|\fB\-\-yes\fP
 .ad b
 .br
 .ad l
- \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .ad b
 .SH DESCRIPTION
 lvchange changes LV attributes in the VG, changes LV activation in the
@@ -232,87 +232,87 @@ required, after which the others are optional.
 .P
 \fBlvchange\fP
 .RS 4
-( \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP,
+( \fB-C\fP|\fB\-\-contiguous\fP \fBy\fP|\fBn\fP,
 .ad b
 .br
 .ad l
-  \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP,
+  \fB-p\fP|\fB\-\-permission\fP \fBrw\fP|\fBr\fP,
 .ad b
 .br
 .ad l
-  \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP,
+  \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP,
 .ad b
 .br
 .ad l
-  \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP,
+  \fB-k\fP|\fB\-\-setactivationskip\fP \fBy\fP|\fBn\fP,
 .ad b
 .br
 .ad l
-  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP,
+  \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP,
 .ad b
 .br
 .ad l
-  \fB-M\fP|\fB--persistent\fP \fBn\fP,
+  \fB-M\fP|\fB\-\-persistent\fP \fBn\fP,
 .ad b
 .br
 .ad l
-     \fB--addtag\fP \fITag\fP,
+     \fB\-\-addtag\fP \fITag\fP,
 .ad b
 .br
 .ad l
-     \fB--deltag\fP \fITag\fP,
+     \fB\-\-deltag\fP \fITag\fP,
 .ad b
 .br
 .ad l
-     \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP,
+     \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP,
 .ad b
 .br
 .ad l
-     \fB--detachprofile\fP,
+     \fB\-\-detachprofile\fP,
 .ad b
 .br
 .ad l
-     \fB--metadataprofile\fP \fIString\fP,
+     \fB\-\-metadataprofile\fP \fIString\fP,
 .ad b
 .br
 .ad l
-     \fB--profile\fP \fIString\fP,
+     \fB\-\-profile\fP \fIString\fP,
 .ad b
 .br
 .ad l
-     \fB--errorwhenfull\fP \fBy\fP|\fBn\fP,
+     \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP,
 .ad b
 .br
 .ad l
-     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP,
+     \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP,
 .ad b
 .br
 .ad l
-     \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP,
+     \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP,
 .ad b
 .br
 .ad l
-     \fB--cachepolicy\fP \fIString\fP,
+     \fB\-\-cachepolicy\fP \fIString\fP,
 .ad b
 .br
 .ad l
-     \fB--cachesettings\fP \fIString\fP,
+     \fB\-\-cachesettings\fP \fIString\fP,
 .ad b
 .br
 .ad l
-     \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT],
+     \fB\-\-[raid]minrecoveryrate\fP \fISize\fP[k|UNIT],
 .ad b
 .br
 .ad l
-     \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT],
+     \fB\-\-[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT],
 .ad b
 .br
 .ad l
-     \fB--[raid]writebehind\fP \fINumber\fP,
+     \fB\-\-[raid]writebehind\fP \fINumber\fP,
 .ad b
 .br
 .ad l
-     \fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP] )
+     \fB\-\-[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP] )
 .RE
 .RS 4
  \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
@@ -320,7 +320,7 @@ required, after which the others are optional.
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+[ \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -331,11 +331,11 @@ required, after which the others are optional.
 Resyncronize a mirror or raid LV.
 .br
 .P
-\fBlvchange\fP \fB--resync\fP \fIVG\fP|\fILV\fP\fI_mirror_raid\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB\-\-resync\fP \fIVG\fP|\fILV\fP\fI_mirror_raid\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+[ \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -346,7 +346,7 @@ Resyncronize a mirror or raid LV.
 Resynchronize or check a raid LV.
 .br
 .P
-\fBlvchange\fP \fB--syncaction\fP \fBcheck\fP|\fBrepair\fP \fIVG\fP|\fILV\fP\fI_raid\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB\-\-syncaction\fP \fBcheck\fP|\fBrepair\fP \fIVG\fP|\fILV\fP\fI_raid\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -357,7 +357,7 @@ Resynchronize or check a raid LV.
 Reconstruct data on specific PVs of a raid LV.
 .br
 .P
-\fBlvchange\fP \fB--rebuild\fP \fIPV\fP \fIVG\fP|\fILV\fP\fI_raid\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB\-\-rebuild\fP \fIPV\fP \fIVG\fP|\fILV\fP\fI_raid\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -368,27 +368,27 @@ Reconstruct data on specific PVs of a raid LV.
 Activate or deactivate an LV.
 .br
 .P
-\fBlvchange\fP \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+[ \fB-K\fP|\fB\-\-ignoreactivationskip\fP ]
 .ad b
 .br
 .ad l
-[    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
+[    \fB\-\-activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--sysinit\fP ]
+[    \fB\-\-sysinit\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -399,15 +399,15 @@ Activate or deactivate an LV.
 Reactivate an LV using the latest metadata.
 .br
 .P
-\fBlvchange\fP \fB--refresh\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB\-\-refresh\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -418,11 +418,11 @@ Reactivate an LV using the latest metadata.
 Start or stop monitoring an LV from dmeventd.
 .br
 .P
-\fBlvchange\fP \fB--monitor\fP \fBy\fP|\fBn\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB\-\-monitor\fP \fBy\fP|\fBn\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 .ad l
-[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -433,11 +433,11 @@ Start or stop monitoring an LV from dmeventd.
 Start or stop processing an LV conversion.
 .br
 .P
-\fBlvchange\fP \fB--poll\fP \fBy\fP|\fBn\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
+\fBlvchange\fP \fB\-\-poll\fP \fBy\fP|\fBn\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
 .ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-monitor\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -448,11 +448,11 @@ Start or stop processing an LV conversion.
 Make the minor device number persistent for an LV.
 .br
 .P
-\fBlvchange\fP \fB-M\fP|\fB--persistent\fP \fBy\fP \fB--minor\fP \fINumber\fP \fILV\fP
+\fBlvchange\fP \fB-M\fP|\fB\-\-persistent\fP \fBy\fP \fB\-\-minor\fP \fINumber\fP \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+[ \fB-j\fP|\fB\-\-major\fP \fINumber\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -464,31 +464,31 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoremonitoring\fP ]
+[    \fB\-\-ignoremonitoring\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -496,57 +496,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+\fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
 Change the active state of LVs.
 An active LV can be used through a block device,
@@ -571,7 +571,7 @@ See clvmd(8) for more information about activation options \fBey\fP, \fBsy\fP, \
 .ad b
 .HP
 .ad l
-\fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
+\fB\-\-activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .br
 Determines if LV activation is allowed when PVs are missing,
 e.g. because of a device failure.
@@ -586,14 +586,14 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--addtag\fP \fITag\fP
+\fB\-\-addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -614,14 +614,14 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
+\fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
@@ -637,14 +637,14 @@ block invalidates. See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--cachepolicy\fP \fIString\fP
+\fB\-\-cachepolicy\fP \fIString\fP
 .br
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--cachesettings\fP \fIString\fP
+\fB\-\-cachesettings\fP \fIString\fP
 .br
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
@@ -656,14 +656,14 @@ See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -672,7 +672,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
+\fB-C\fP|\fB\-\-contiguous\fP \fBy\fP|\fBn\fP
 .br
 Sets or resets the contiguous allocation policy for LVs.
 Default is no contiguous allocation based on a next free principle.
@@ -682,28 +682,28 @@ are already contiguous.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--deltag\fP \fITag\fP
+\fB\-\-deltag\fP \fITag\fP
 .br
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
 .HP
 .ad l
-\fB--detachprofile\fP
+\fB\-\-detachprofile\fP
 .br
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
+\fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
@@ -716,14 +716,14 @@ See \fBlvmthin\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--errorwhenfull\fP \fBy\fP|\fBn\fP
+\fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
 Specifies thin pool behavior when data space is exhausted.
 When yes, device-mapper will immediately return an error
@@ -736,60 +736,60 @@ See \fBlvmthin\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-K\fP|\fB--ignoreactivationskip\fP
+\fB-K\fP|\fB\-\-ignoreactivationskip\fP
 .br
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoremonitoring\fP
+\fB\-\-ignoremonitoring\fP
 .br
-Do not interact with dmeventd unless --monitor is specified.
+Do not interact with dmeventd unless \-\-monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-j\fP|\fB--major\fP \fINumber\fP
+\fB-j\fP|\fB\-\-major\fP \fINumber\fP
 .br
 Sets the major number of an LV block device.
 .ad b
 .HP
 .ad l
-\fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
+\fB\-\-[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
 Sets the maximum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
@@ -798,20 +798,20 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--metadataprofile\fP \fIString\fP
+\fB\-\-metadataprofile\fP \fIString\fP
 .br
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--minor\fP \fINumber\fP
+\fB\-\-minor\fP \fINumber\fP
 .br
 Sets the minor number of an LV block device.
 .ad b
 .HP
 .ad l
-\fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
+\fB\-\-[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
 Sets the minimum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
@@ -820,7 +820,7 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--monitor\fP \fBy\fP|\fBn\fP
+\fB\-\-monitor\fP \fBy\fP|\fBn\fP
 .br
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
@@ -829,7 +829,7 @@ See dmeventd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -838,7 +838,7 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -847,45 +847,45 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
+\fB-p\fP|\fB\-\-permission\fP \fBrw\fP|\fBr\fP
 .br
 Set access permission to read only \fBr\fP or read and write \fBrw\fP.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
+\fB-M\fP|\fB\-\-persistent\fP \fBy\fP|\fBn\fP
 .br
 When yes, makes the specified minor number persistent.
 .ad b
 .HP
 .ad l
-\fB--poll\fP \fBy\fP|\fBn\fP
+\fB\-\-poll\fP \fBy\fP|\fBn\fP
 .br
 When yes, start the background transformation of an LV.
 An incomplete transformation, e.g. pvmove or lvconvert interrupted
-by reboot or crash, can be restarted from the last checkpoint with --poll y.
+by reboot or crash, can be restarted from the last checkpoint with \-\-poll y.
 When no, background transformation of an LV will not occur, and the
 transformation will not complete. It may not be appropriate to immediately
-poll an LV after activation, in which case --poll n can be used to defer
-polling until a later --poll y command.
+poll an LV after activation, in which case \-\-poll n can be used to defer
+polling until a later \-\-poll y command.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
+\fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
@@ -894,18 +894,18 @@ a suitable value automatically.
 .ad b
 .HP
 .ad l
-\fB--rebuild\fP \fIPV\fP
+\fB\-\-rebuild\fP \fIPV\fP
 .br
 Selects a PV to rebuild in a raid LV. Multiple PVs can be rebuilt by
 repeating this option.
-Use this option in place of --resync or --syncaction repair when the
+Use this option in place of \-\-resync or \-\-syncaction repair when the
 PVs with corrupted data are known, and their data should be reconstructed
 rather than reconstructing default (rotating) data.
 See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--refresh\fP
+\fB\-\-refresh\fP
 .br
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
@@ -914,7 +914,7 @@ sharing is being used.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -925,11 +925,11 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--resync\fP
+\fB\-\-resync\fP
 .br
 Initiates mirror synchronization. Synchronization generally happens
 automatically, but this option forces it to run.
-Also see --rebuild to synchronize a specific PV.
+Also see \-\-rebuild to synchronize a specific PV.
 During synchronization, data is read from the primary mirror device
 and copied to the others. This can take considerable time, during
 which the LV is without a complete redundant copy of the data.
@@ -937,12 +937,12 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -950,18 +950,18 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
+\fB-k\fP|\fB\-\-setactivationskip\fP \fBy\fP|\fBn\fP
 .br
 Persistently sets (yes) or clears (no) the "activation skip" flag on an LV.
 An LV with this flag set is not activated unless the
---ignoreactivationskip option is used by the activation command.
+\-\-ignoreactivationskip option is used by the activation command.
 This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
 .ad b
 .HP
 .ad l
-\fB--[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
+\fB\-\-[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
 .br
 Initiate different types of RAID synchronization.
 This causes the RAID LV to read all data and parity
@@ -973,20 +973,20 @@ See lvs for reporting discrepancies found or repaired.
 .ad b
 .HP
 .ad l
-\fB--sysinit\fP
+\fB\-\-sysinit\fP
 .br
 Indicates that vgchange/lvchange is being invoked from early system initialisation
 scripts (e.g. rc.sysinit or an initrd), before writable filesystems are
 available. As such, some functionality needs to be disabled and this option
 acts as a shortcut which selects an appropriate set of options. Currently,
-this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
---poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
+this is equivalent to using \-\-ignorelockingfailure, \-\-ignoremonitoring,
+\-\-poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
 When used in conjunction with lvmetad enabled and running,
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -996,20 +996,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB--[raid]writebehind\fP \fINumber\fP
+\fB\-\-[raid]writebehind\fP \fINumber\fP
 .br
 The maximum number of outstanding writes that are allowed to
 devices in a RAID1 LV that is marked write-mostly.
@@ -1020,7 +1020,7 @@ and allows the system to choose the value arbitrarily.
 .ad b
 .HP
 .ad l
-\fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
+\fB\-\-[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
 .br
 Mark a device in a RAID1 LV as write-mostly.  All reads
 to these drives will be avoided unless absolutely necessary. This keeps
@@ -1033,7 +1033,7 @@ multiple PVs.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -1041,10 +1041,10 @@ answer yes. Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+\fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .br
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
-in non-zero mode are not cleared in unwritten parts when setting --zero y.
+in non-zero mode are not cleared in unwritten parts when setting \-\-zero y.
 .ad b
 .SH VARIABLES
 .HP
@@ -1067,7 +1067,7 @@ in place of a VG, LV or PV.
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
-be omitted if the \fB--select\fP option is used.
+be omitted if the \fB\-\-select\fP option is used.
 No arg appears in this position.
 .HP
 \fIString\fP
@@ -1084,7 +1084,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvconvert.8_end b/man/lvconvert.8_end
index a329acd..bbc50a7 100644
--- a/man/lvconvert.8_end
+++ b/man/lvconvert.8_end
@@ -1,7 +1,7 @@
 .SH NOTES
 This previous command syntax would perform two different operations:
 .br
-\fBlvconvert --thinpool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
+\fBlvconvert \-\-thinpool\fP \fILV1\fP \fB\-\-poolmetadata\fP \fILV2\fP
 .br
 If LV1 was not a thin pool, the command would convert LV1 to
 a thin pool, optionally using a specified LV for metadata.
@@ -11,7 +11,7 @@ the current metadata LV with LV2 (for repair purposes.)
 In the same way, this previous command syntax would perform two different
 operations:
 .br
-\fBlvconvert --cachepool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
+\fBlvconvert \-\-cachepool\fP \fILV1\fP \fB\-\-poolmetadata\fP \fILV2\fP
 .br
 If LV1 was not a cache pool, the command would convert LV1 to
 a cache pool, optionally using a specified LV for metadata.
@@ -36,7 +36,7 @@ Convert a mirror LV to use a disk log.
 
 Convert a mirror or raid1 LV to a linear LV.
 .br
-.B lvconvert --type linear vg/lvol1
+.B lvconvert \-\-type linear vg/lvol1
 
 Convert a mirror LV to a raid1 LV with the same number of images.
 .br
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 97c01bc..ba7beb4 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -11,227 +11,227 @@ lvconvert \- Change logical volume layout
 .br
 .P
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
 .br
 .ad l
- \fB-b\fP|\fB--background\fP
+ \fB-b\fP|\fB\-\-background\fP
 .ad b
 .br
 .ad l
- \fB-H\fP|\fB--cache\fP
+ \fB-H\fP|\fB\-\-cache\fP
 .ad b
 .br
 .ad l
-    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
+    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .ad b
 .br
 .ad l
-    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
+    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .ad b
 .br
 .ad l
-    \fB--cachepolicy\fP \fIString\fP
+    \fB\-\-cachepolicy\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--cachepool\fP \fILV\fP
+    \fB\-\-cachepool\fP \fILV\fP
 .ad b
 .br
 .ad l
-    \fB--cachesettings\fP \fIString\fP
+    \fB\-\-cachesettings\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
+ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
-    \fB--commandprofile\fP \fIString\fP
+    \fB\-\-commandprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--config\fP \fIString\fP
+    \fB\-\-config\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-d\fP|\fB--debug\fP
+ \fB-d\fP|\fB\-\-debug\fP
 .ad b
 .br
 .ad l
-    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
+    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .ad b
 .br
 .ad l
-    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-f\fP|\fB--force\fP
+ \fB-f\fP|\fB\-\-force\fP
 .ad b
 .br
 .ad l
- \fB-h\fP|\fB--help\fP
+ \fB-h\fP|\fB\-\-help\fP
 .ad b
 .br
 .ad l
- \fB-i\fP|\fB--interval\fP \fINumber\fP
+ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--longhelp\fP
+    \fB\-\-longhelp\fP
 .ad b
 .br
 .ad l
-    \fB--merge\fP
+    \fB\-\-merge\fP
 .ad b
 .br
 .ad l
-    \fB--mergemirrors\fP
+    \fB\-\-mergemirrors\fP
 .ad b
 .br
 .ad l
-    \fB--mergesnapshot\fP
+    \fB\-\-mergesnapshot\fP
 .ad b
 .br
 .ad l
-    \fB--mergethin\fP
+    \fB\-\-mergethin\fP
 .ad b
 .br
 .ad l
-    \fB--metadataprofile\fP \fIString\fP
+    \fB\-\-metadataprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
+    \fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .ad b
 .br
 .ad l
- \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
+ \fB-m\fP|\fB\-\-mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
 .ad b
 .br
 .ad l
- \fB-n\fP|\fB--name\fP \fIString\fP
+ \fB-n\fP|\fB\-\-name\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--noudevsync\fP
+    \fB\-\-noudevsync\fP
 .ad b
 .br
 .ad l
-    \fB--originname\fP \fILV\fP
+    \fB\-\-originname\fP \fILV\fP
 .ad b
 .br
 .ad l
-    \fB--poolmetadata\fP \fILV\fP
+    \fB\-\-poolmetadata\fP \fILV\fP
 .ad b
 .br
 .ad l
-    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
+    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
-    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
+    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--profile\fP \fIString\fP
+    \fB\-\-profile\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-q\fP|\fB--quiet\fP
+ \fB-q\fP|\fB\-\-quiet\fP
 .ad b
 .br
 .ad l
- \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
+ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .ad b
 .br
 .ad l
- \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
+ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
-    \fB--repair\fP
+    \fB\-\-repair\fP
 .ad b
 .br
 .ad l
-    \fB--replace\fP \fIPV\fP
+    \fB\-\-replace\fP \fIPV\fP
 .ad b
 .br
 .ad l
- \fB-s\fP|\fB--snapshot\fP
+ \fB-s\fP|\fB\-\-snapshot\fP
 .ad b
 .br
 .ad l
-    \fB--splitcache\fP
+    \fB\-\-splitcache\fP
 .ad b
 .br
 .ad l
-    \fB--splitmirrors\fP \fINumber\fP
+    \fB\-\-splitmirrors\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--splitsnapshot\fP
+    \fB\-\-splitsnapshot\fP
 .ad b
 .br
 .ad l
-    \fB--startpoll\fP
+    \fB\-\-startpoll\fP
 .ad b
 .br
 .ad l
-    \fB--stripes\fP \fINumber\fP
+    \fB\-\-stripes\fP \fINumber\fP
 .ad b
 .br
 .ad l
- \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
+ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
-    \fB--swapmetadata\fP
+    \fB\-\-swapmetadata\fP
 .ad b
 .br
 .ad l
- \fB-t\fP|\fB--test\fP
+ \fB-t\fP|\fB\-\-test\fP
 .ad b
 .br
 .ad l
- \fB-T\fP|\fB--thin\fP
+ \fB-T\fP|\fB\-\-thin\fP
 .ad b
 .br
 .ad l
-    \fB--thinpool\fP \fILV\fP
+    \fB\-\-thinpool\fP \fILV\fP
 .ad b
 .br
 .ad l
-    \fB--trackchanges\fP
+    \fB\-\-trackchanges\fP
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+    \fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
 .ad b
 .br
 .ad l
-    \fB--uncache\fP
+    \fB\-\-uncache\fP
 .ad b
 .br
 .ad l
-    \fB--usepolicies\fP
+    \fB\-\-usepolicies\fP
 .ad b
 .br
 .ad l
- \fB-v\fP|\fB--verbose\fP
+ \fB-v\fP|\fB\-\-verbose\fP
 .ad b
 .br
 .ad l
-    \fB--version\fP
+    \fB\-\-version\fP
 .ad b
 .br
 .ad l
- \fB-y\fP|\fB--yes\fP
+ \fB-y\fP|\fB\-\-yes\fP
 .ad b
 .br
 .ad l
- \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .ad b
 .SH DESCRIPTION
 lvconvert changes the LV type and includes utilities for LV data
@@ -302,7 +302,7 @@ Sub LVs can be displayed with the command
 Convert LV to linear.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBlinear\fP \fILV\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBlinear\fP \fILV\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -316,23 +316,23 @@ Convert LV to linear.
 Convert LV to striped.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBstriped\fP \fILV\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBstriped\fP \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--stripes\fP \fINumber\fP ]
+[    \fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -348,27 +348,27 @@ Convert LV to raid or change raid layout
 (a specific raid level must be used, e.g. raid1).
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBraid\fP \fILV\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBraid\fP \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
+[ \fB-m\fP|\fB\-\-mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--stripes\fP \fINumber\fP ]
+[    \fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -382,19 +382,19 @@ Convert LV to raid or change raid layout
 Convert LV to raid1 or mirror, or change number of mirror images.
 .br
 .P
-\fBlvconvert\fP \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP \fILV\fP
+\fBlvconvert\fP \fB-m\fP|\fB\-\-mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
+[    \fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -408,19 +408,19 @@ Convert LV to raid1 or mirror, or change number of mirror images.
 Convert raid LV to change number of stripe images.
 .br
 .P
-\fBlvconvert\fP \fB--stripes\fP \fINumber\fP \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB\-\-stripes\fP \fINumber\fP \fILV\fP\fI_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -434,15 +434,15 @@ Convert raid LV to change number of stripe images.
 Convert raid LV to change the stripe size.
 .br
 .P
-\fBlvconvert\fP \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] \fILV\fP\fI_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -453,7 +453,7 @@ Convert raid LV to change the stripe size.
 Split images from a raid1 or mirror LV and use them to create a new LV.
 .br
 .P
-\fBlvconvert\fP \fB--splitmirrors\fP \fINumber\fP \fB-n\fP|\fB--name\fP \fILV\fP\fI_new\fP \fILV\fP\fI_cache_mirror_raid1\fP
+\fBlvconvert\fP \fB\-\-splitmirrors\fP \fINumber\fP \fB-n\fP|\fB\-\-name\fP \fILV\fP\fI_new\fP \fILV\fP\fI_cache_mirror_raid1\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -467,7 +467,7 @@ Split images from a raid1 or mirror LV and use them to create a new LV.
 Split images from a raid1 LV and track changes to origin.
 .br
 .P
-\fBlvconvert\fP \fB--splitmirrors\fP \fINumber\fP \fB--trackchanges\fP \fILV\fP\fI_cache_raid1\fP
+\fBlvconvert\fP \fB\-\-splitmirrors\fP \fINumber\fP \fB\-\-trackchanges\fP \fILV\fP\fI_cache_raid1\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -481,7 +481,7 @@ Split images from a raid1 LV and track changes to origin.
 Merge LV images that were split from a raid1 LV.
 .br
 .P
-\fBlvconvert\fP \fB--mergemirrors\fP \fIVG\fP|\fILV\fP\fI_linear_raid\fP|\fITag\fP ...
+\fBlvconvert\fP \fB\-\-mergemirrors\fP \fIVG\fP|\fILV\fP\fI_linear_raid\fP|\fITag\fP ...
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -492,43 +492,43 @@ Merge LV images that were split from a raid1 LV.
 Convert LV to a thin LV, using the original LV as an external origin.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBthin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBthin\fP \fB\-\-thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_cache_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--originname\fP \fILV\fP\fI_new\fP ]
+[    \fB\-\-originname\fP \fILV\fP\fI_new\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadata\fP \fILV\fP ]
+[    \fB\-\-poolmetadata\fP \fILV\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -539,55 +539,55 @@ Convert LV to a thin LV, using the original LV as an external origin.
 Convert LV to type cache.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBcache\fP \fB\-\-cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-H\fP|\fB--cache\fP ]
+[ \fB-H\fP|\fB\-\-cache\fP ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadata\fP \fILV\fP ]
+[    \fB\-\-poolmetadata\fP \fILV\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -598,47 +598,47 @@ Convert LV to type cache.
 Convert LV to type thin-pool.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBthin-pool\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBthin-pool\fP \fILV\fP\fI_linear_striped_cache_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--stripes\fP \fINumber\fP ]
+[    \fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadata\fP \fILV\fP ]
+[    \fB\-\-poolmetadata\fP \fILV\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -652,51 +652,51 @@ Convert LV to type thin-pool.
 Convert LV to type cache-pool.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBcache-pool\fP \fILV\fP\fI_linear_striped_raid\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBcache-pool\fP \fILV\fP\fI_linear_striped_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadata\fP \fILV\fP ]
+[    \fB\-\-poolmetadata\fP \fILV\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -710,7 +710,7 @@ Convert LV to type cache-pool.
 Separate and keep the cache pool from a cache LV.
 .br
 .P
-\fBlvconvert\fP \fB--splitcache\fP \fILV\fP\fI_thinpool_cache_cachepool\fP
+\fBlvconvert\fP \fB\-\-splitcache\fP \fILV\fP\fI_thinpool_cache_cachepool\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -721,7 +721,7 @@ Separate and keep the cache pool from a cache LV.
 Merge thin LV into its origin LV.
 .br
 .P
-\fBlvconvert\fP \fB--mergethin\fP \fILV\fP\fI_thin\fP ...
+\fBlvconvert\fP \fB\-\-mergethin\fP \fILV\fP\fI_thin\fP ...
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -732,11 +732,11 @@ Merge thin LV into its origin LV.
 Merge COW snapshot LV into its origin.
 .br
 .P
-\fBlvconvert\fP \fB--mergesnapshot\fP \fILV\fP\fI_snapshot\fP ...
+\fBlvconvert\fP \fB\-\-mergesnapshot\fP \fILV\fP\fI_snapshot\fP ...
 .br
 .RS 4
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -749,15 +749,15 @@ Replace failed PVs in a raid or mirror LV.
 Repair a thin pool.
 .br
 .P
-\fBlvconvert\fP \fB--repair\fP \fILV\fP\fI_thinpool_mirror_raid\fP
+\fBlvconvert\fP \fB\-\-repair\fP \fILV\fP\fI_thinpool_mirror_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--usepolicies\fP ]
+[    \fB\-\-usepolicies\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -771,7 +771,7 @@ Repair a thin pool.
 Replace specific PV(s) in a raid LV with another PV.
 .br
 .P
-\fBlvconvert\fP \fB--replace\fP \fIPV\fP \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB\-\-replace\fP \fIPV\fP \fILV\fP\fI_raid\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -785,7 +785,7 @@ Replace specific PV(s) in a raid LV with another PV.
 Poll LV to continue conversion.
 .br
 .P
-\fBlvconvert\fP \fB--startpoll\fP \fILV\fP\fI_mirror_raid\fP
+\fBlvconvert\fP \fB\-\-startpoll\fP \fILV\fP\fI_mirror_raid\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -797,19 +797,19 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-b\fP|\fB--background\fP ]
+[ \fB-b\fP|\fB\-\-background\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .RE
 
@@ -817,57 +817,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -888,7 +888,7 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP
+\fB-b\fP|\fB\-\-background\fP
 .br
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
@@ -896,21 +896,21 @@ background.
 .ad b
 .HP
 .ad l
-\fB-H\fP|\fB--cache\fP
+\fB-H\fP|\fB\-\-cache\fP
 .br
 Specifies the command is handling a cache LV or cache pool.
-See --type cache and --type cache-pool.
+See \-\-type cache and \-\-type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
 .ad b
 .HP
 .ad l
-\fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
+\fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
 Specifies the cache metadata format used by cache target.
 .ad b
 .HP
 .ad l
-\fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
+\fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
@@ -926,20 +926,20 @@ block invalidates. See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--cachepolicy\fP \fIString\fP
+\fB\-\-cachepolicy\fP \fIString\fP
 .br
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--cachepool\fP \fILV\fP
+\fB\-\-cachepool\fP \fILV\fP
 .br
 The name of a cache pool LV.
 .ad b
 .HP
 .ad l
-\fB--cachesettings\fP \fIString\fP
+\fB\-\-cachesettings\fP \fIString\fP
 .br
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
@@ -951,7 +951,7 @@ See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
+\fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT]
 .br
 The size of chunks in a snapshot, cache pool or thin pool.
 For snapshots, the value must be a power of 2 between 4KiB and 512KiB
@@ -966,14 +966,14 @@ See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -982,14 +982,14 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
+\fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
@@ -1002,53 +1002,53 @@ See \fBlvmthin\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-i\fP|\fB--interval\fP \fINumber\fP
+\fB-i\fP|\fB\-\-interval\fP \fINumber\fP
 .br
 Report progress at regular intervals.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--merge\fP
+\fB\-\-merge\fP
 .br
-An alias for --mergethin, --mergemirrors, or --mergesnapshot,
+An alias for \-\-mergethin, \-\-mergemirrors, or \-\-mergesnapshot,
 depending on the type of LV.
 .ad b
 .HP
 .ad l
-\fB--mergemirrors\fP
+\fB\-\-mergemirrors\fP
 .br
 Merge LV images that were split from a raid1 LV.
-See --splitmirrors with --trackchanges.
+See \-\-splitmirrors with \-\-trackchanges.
 .ad b
 .HP
 .ad l
-\fB--mergesnapshot\fP
+\fB\-\-mergesnapshot\fP
 .br
 Merge COW snapshot LV into its origin.
 When merging a snapshot, if both the origin and snapshot LVs are not open,
@@ -1065,7 +1065,7 @@ used to specify multiple snapshots be merged to their respective origin.
 .ad b
 .HP
 .ad l
-\fB--mergethin\fP
+\fB\-\-mergethin\fP
 .br
 Merge thin LV into its origin LV.
 The origin thin LV takes the content of the thin snapshot,
@@ -1074,14 +1074,14 @@ See \fBlvmthin\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--metadataprofile\fP \fIString\fP
+\fB\-\-metadataprofile\fP \fIString\fP
 .br
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
+\fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .br
 Specifies the type of mirror log for LVs with the "mirror" type
 (does not apply to the "raid1" type.)
@@ -1094,16 +1094,16 @@ the first device to others) each time the LV is activated, e.g. after reboot.
 .ad b
 .HP
 .ad l
-\fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
+\fB-m\fP|\fB\-\-mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
 .br
 Specifies the number of mirror images in addition to the original LV
-image, e.g. --mirrors 1 means there are two images of the data, the
+image, e.g. \-\-mirrors 1 means there are two images of the data, the
 original and one mirror image.
 Optional positional PV args on the command line can specify the devices
 the images should be placed on.
 There are two mirroring implementations: "raid1" and "mirror".
 These are the names of the corresponding LV types, or "segment types".
-Use the --type option to specify which to use (raid1 is default,
+Use the \-\-type option to specify which to use (raid1 is default,
 and mirror is legacy)
 Use lvm.conf global/mirror_segtype_default and
 global/raid10_segtype_default to configure the default types.
@@ -1115,7 +1115,7 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-n\fP|\fB--name\fP \fIString\fP
+\fB-n\fP|\fB\-\-name\fP \fIString\fP
 .br
 Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
@@ -1123,7 +1123,7 @@ generated, where # is a number generated by LVM.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -1132,7 +1132,7 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB--originname\fP \fILV\fP
+\fB\-\-originname\fP \fILV\fP
 .br
 Specifies the name to use for the external origin LV when converting an LV
 to a thin LV. The LV being converted becomes a read-only external origin
@@ -1140,19 +1140,19 @@ with this name.
 .ad b
 .HP
 .ad l
-\fB--poolmetadata\fP \fILV\fP
+\fB\-\-poolmetadata\fP \fILV\fP
 .br
 The name of a an LV to use for storing pool metadata.
 .ad b
 .HP
 .ad l
-\fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
+\fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
 Specifies the size of the new pool metadata LV.
 .ad b
 .HP
 .ad l
-\fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
+\fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP
 .br
 Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
@@ -1160,21 +1160,21 @@ space that can be used when repairing a pool.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
+\fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
@@ -1183,7 +1183,7 @@ a suitable value automatically.
 .ad b
 .HP
 .ad l
-\fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
+\fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT]
 .br
 Size of each raid or mirror synchronization region.
 lvm.conf activation/raid_region_size can be used to
@@ -1191,7 +1191,7 @@ configure a default.
 .ad b
 .HP
 .ad l
-\fB--repair\fP
+\fB\-\-repair\fP
 .br
 Replace failed PVs in a raid or mirror LV, or run a repair
 utility on a thin pool. See \fBlvmraid\fP(7) and \fBlvmthin\fP(7)
@@ -1199,7 +1199,7 @@ for more information.
 .ad b
 .HP
 .ad l
-\fB--replace\fP \fIPV\fP
+\fB\-\-replace\fP \fIPV\fP
 .br
 Replace a specific PV in a raid LV with another PV.
 The new PV to use can be optionally specified after the LV.
@@ -1208,29 +1208,29 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-s\fP|\fB--snapshot\fP
+\fB-s\fP|\fB\-\-snapshot\fP
 .br
 Combine a former COW snapshot LV with a former origin LV to reverse
-a previous --splitsnapshot command.
+a previous \-\-splitsnapshot command.
 .ad b
 .HP
 .ad l
-\fB--splitcache\fP
+\fB\-\-splitcache\fP
 .br
 Separates a cache pool from a cache LV, and keeps the unused cache pool LV.
-Before the separation, the cache is flushed. Also see --uncache.
+Before the separation, the cache is flushed. Also see \-\-uncache.
 .ad b
 .HP
 .ad l
-\fB--splitmirrors\fP \fINumber\fP
+\fB\-\-splitmirrors\fP \fINumber\fP
 .br
 Splits the specified number of images from a raid1 or mirror LV
-and uses them to create a new LV. If --trackchanges is also specified,
+and uses them to create a new LV. If \-\-trackchanges is also specified,
 changes to the raid1 LV are tracked while the split LV remains detached.
 .ad b
 .HP
 .ad l
-\fB--splitsnapshot\fP
+\fB\-\-splitsnapshot\fP
 .br
 Separates a COW snapshot from its origin LV. The LV that is split off
 contains the chunks that differ from the origin LV along with metadata
@@ -1238,30 +1238,30 @@ describing them. This LV can be wiped and then destroyed with lvremove.
 .ad b
 .HP
 .ad l
-\fB--startpoll\fP
+\fB\-\-startpoll\fP
 .br
 Start polling an LV to continue processing a conversion.
 .ad b
 .HP
 .ad l
-\fB--stripes\fP \fINumber\fP
+\fB\-\-stripes\fP \fINumber\fP
 .br
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
-the stripe size (see --stripesize). This does not apply to
+the stripe size (see \-\-stripesize). This does not apply to
 existing allocated space, only newly allocated space can be striped.
 .ad b
 .HP
 .ad l
-\fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
+\fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT]
 .br
 The amount of data that is written to one device before
 moving to the next in a striped LV.
 .ad b
 .HP
 .ad l
-\fB--swapmetadata\fP
+\fB\-\-swapmetadata\fP
 .br
 Extracts the metadata LV from a pool and replaces it with another specified LV.
 The extracted LV is preserved and given the name of the LV that replaced it.
@@ -1272,7 +1272,7 @@ be activated directly and used with thin provisioning tools:
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -1282,23 +1282,23 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-T\fP|\fB--thin\fP
+\fB-T\fP|\fB\-\-thin\fP
 .br
 Specifies the command is handling a thin LV or thin pool.
-See --type thin, --type thin-pool, and --virtualsize.
+See \-\-type thin, \-\-type thin-pool, and \-\-virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
 .ad b
 .HP
 .ad l
-\fB--thinpool\fP \fILV\fP
+\fB\-\-thinpool\fP \fILV\fP
 .br
 The name of a thin pool LV.
 .ad b
 .HP
 .ad l
-\fB--trackchanges\fP
+\fB\-\-trackchanges\fP
 .br
-Can be used with --splitmirrors on a raid1 LV. This causes
+Can be used with \-\-splitmirrors on a raid1 LV. This causes
 changes to the original raid1 LV to be tracked while the split images
 remain detached. This allows the read-only detached image(s) to be
 merged efficiently back into the raid1 LV later. Only the regions with
@@ -1307,7 +1307,7 @@ when using the raid1 LV type.)
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+\fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
@@ -1317,39 +1317,39 @@ For performance caching (\fBcache\fP, \fBcache-pool\fP) see \fBlvmcache\fP(7).
 For copy-on-write snapshots (\fBsnapshot\fP) see usage definitions.
 Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
-(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
+(e.g. \-\-stripes, \-\-mirrors, \-\-snapshot, \-\-virtualsize, \-\-thin, \-\-cache).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP
 .ad l
-\fB--uncache\fP
+\fB\-\-uncache\fP
 .br
 Separates a cache pool from a cache LV, and deletes the unused cache pool LV.
-Before the separation, the cache is flushed. Also see --splitcache.
+Before the separation, the cache is flushed. Also see \-\-splitcache.
 .ad b
 .HP
 .ad l
-\fB--usepolicies\fP
+\fB\-\-usepolicies\fP
 .br
 Perform an operation according to the policy configured in lvm.conf
 or a profile.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -1357,7 +1357,7 @@ answer yes. Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+\fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .br
 For snapshots, this controls zeroing of the first 4KiB of data in the
 snapshot. If the LV is read-only, the snapshot will not be zeroed.
@@ -1406,7 +1406,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
@@ -1416,26 +1416,26 @@ Alternate command forms, advanced command usage, and listing of all valid syntax
 .P
 Convert LV to type mirror (also see type raid1), 
 .br
-(also see lvconvert --mirrors).
+(also see lvconvert \-\-mirrors).
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBmirror\fP \fILV\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBmirror\fP \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
+[ \fB-m\fP|\fB\-\-mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
+[    \fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1449,7 +1449,7 @@ Convert LV to type mirror (also see type raid1),
 Change the region size of an LV.
 .br
 .P
-\fBlvconvert\fP \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_raid\fP
+\fBlvconvert\fP \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_raid\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -1460,7 +1460,7 @@ Change the region size of an LV.
 Change the type of mirror log used by a mirror LV.
 .br
 .P
-\fBlvconvert\fP \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP \fILV\fP\fI_mirror\fP
+\fBlvconvert\fP \fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP \fILV\fP\fI_mirror\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -1473,46 +1473,46 @@ Change the type of mirror log used by a mirror LV.
 
 Convert LV to a thin LV, using the original LV as an external origin 
 .br
-(infers --type thin).
+(infers \-\-type thin).
 .br
 .P
-\fBlvconvert\fP \fB-T\fP|\fB--thin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+\fBlvconvert\fP \fB-T\fP|\fB\-\-thin\fP \fB\-\-thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_cache_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--originname\fP \fILV\fP\fI_new\fP ]
+[    \fB\-\-originname\fP \fILV\fP\fI_new\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadata\fP \fILV\fP ]
+[    \fB\-\-poolmetadata\fP \fILV\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1520,58 +1520,58 @@ Convert LV to a thin LV, using the original LV as an external origin
 .br
 -
 
-Convert LV to type cache (infers --type cache).
+Convert LV to type cache (infers \-\-type cache).
 .br
 .P
-\fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+\fBlvconvert\fP \fB-H\fP|\fB\-\-cache\fP \fB\-\-cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
 .br
 .RS 4
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBcache\fP ]
+[    \fB\-\-type\fP \fBcache\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadata\fP \fILV\fP ]
+[    \fB\-\-poolmetadata\fP \fILV\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1582,7 +1582,7 @@ Convert LV to type cache (infers --type cache).
 Separate and delete the cache pool from a cache LV.
 .br
 .P
-\fBlvconvert\fP \fB--uncache\fP \fILV\fP\fI_thinpool_cache\fP
+\fBlvconvert\fP \fB\-\-uncache\fP \fILV\fP\fI_thinpool_cache\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -1593,11 +1593,11 @@ Separate and delete the cache pool from a cache LV.
 Swap metadata LV in a thin pool or cache pool (for repair only).
 .br
 .P
-\fBlvconvert\fP \fB--swapmetadata\fP \fB--poolmetadata\fP \fILV\fP \fILV\fP\fI_thinpool_cachepool\fP
+\fBlvconvert\fP \fB\-\-swapmetadata\fP \fB\-\-poolmetadata\fP \fILV\fP \fILV\fP\fI_thinpool_cachepool\fP
 .br
 .RS 4
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1605,18 +1605,18 @@ Swap metadata LV in a thin pool or cache pool (for repair only).
 .br
 -
 
-Merge LV that was split from a mirror (variant, use --mergemirrors). 
+Merge LV that was split from a mirror (variant, use \-\-mergemirrors). 
 .br
-Merge thin LV into its origin LV (variant, use --mergethin). 
+Merge thin LV into its origin LV (variant, use \-\-mergethin). 
 .br
-Merge COW snapshot LV into its origin (variant, use --mergesnapshot).
+Merge COW snapshot LV into its origin (variant, use \-\-mergesnapshot).
 .br
 .P
-\fBlvconvert\fP \fB--merge\fP \fIVG\fP|\fILV\fP\fI_linear_striped_snapshot_thin_raid\fP|\fITag\fP ...
+\fBlvconvert\fP \fB\-\-merge\fP \fIVG\fP|\fILV\fP\fI_linear_striped_snapshot_thin_raid\fP|\fITag\fP ...
 .br
 .RS 4
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1627,7 +1627,7 @@ Merge COW snapshot LV into its origin (variant, use --mergesnapshot).
 Separate a COW snapshot from its origin LV.
 .br
 .P
-\fBlvconvert\fP \fB--splitsnapshot\fP \fILV\fP\fI_snapshot\fP
+\fBlvconvert\fP \fB\-\-splitsnapshot\fP \fILV\fP\fI_snapshot\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -1640,19 +1640,19 @@ Combine a former COW snapshot (second arg) with a former
 origin LV (first arg) to reverse a splitsnapshot command.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBsnapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
+\fBlvconvert\fP \fB\-\-type\fP \fBsnapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
 .br
 .RS 4
 .ad l
-[ \fB-s\fP|\fB--snapshot\fP ]
+[ \fB-s\fP|\fB\-\-snapshot\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1665,19 +1665,19 @@ Combine a former COW snapshot (second arg) with a former
 origin LV (first arg) to reverse a splitsnapshot command.
 .br
 .P
-\fBlvconvert\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
+\fBlvconvert\fP \fB-s\fP|\fB\-\-snapshot\fP \fILV\fP \fILV\fP\fI_linear\fP
 .br
 .RS 4
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBsnapshot\fP ]
+[    \fB\-\-type\fP \fBsnapshot\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1685,7 +1685,7 @@ origin LV (first arg) to reverse a splitsnapshot command.
 .br
 -
 
-Poll LV to continue conversion (also see --startpoll).
+Poll LV to continue conversion (also see \-\-startpoll).
 .br
 .P
 \fBlvconvert\fP \fILV\fP\fI_mirror_raid\fP
@@ -1699,7 +1699,7 @@ Poll LV to continue conversion (also see --startpoll).
 .SH NOTES
 This previous command syntax would perform two different operations:
 .br
-\fBlvconvert --thinpool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
+\fBlvconvert \-\-thinpool\fP \fILV1\fP \fB\-\-poolmetadata\fP \fILV2\fP
 .br
 If LV1 was not a thin pool, the command would convert LV1 to
 a thin pool, optionally using a specified LV for metadata.
@@ -1709,7 +1709,7 @@ the current metadata LV with LV2 (for repair purposes.)
 In the same way, this previous command syntax would perform two different
 operations:
 .br
-\fBlvconvert --cachepool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
+\fBlvconvert \-\-cachepool\fP \fILV1\fP \fB\-\-poolmetadata\fP \fILV2\fP
 .br
 If LV1 was not a cache pool, the command would convert LV1 to
 a cache pool, optionally using a specified LV for metadata.
@@ -1734,7 +1734,7 @@ Convert a mirror LV to use a disk log.
 
 Convert a mirror or raid1 LV to a linear LV.
 .br
-.B lvconvert --type linear vg/lvol1
+.B lvconvert \-\-type linear vg/lvol1
 
 Convert a mirror LV to a raid1 LV with the same number of images.
 .br
diff --git a/man/lvcreate.8_des b/man/lvcreate.8_des
index 42f4213..a526b85 100644
--- a/man/lvcreate.8_des
+++ b/man/lvcreate.8_des
@@ -26,11 +26,11 @@ virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
 .SS Usage notes
-In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
+with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
 the options section.
 
-In the usage section below, \fB--name\fP is omitted from the required
+In the usage section below, \fB\-\-name\fP is omitted from the required
 options, even though it is typically used.  When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.  Also see the description in the options section.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index ce1c154..cf8bfeb 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -11,235 +11,235 @@ lvcreate \- Create a logical volume
 .br
 .P
 .ad l
- \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+ \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .ad b
 .br
 .ad l
-    \fB--addtag\fP \fITag\fP
+    \fB\-\-addtag\fP \fITag\fP
 .ad b
 .br
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
 .br
 .ad l
- \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-H\fP|\fB--cache\fP
+ \fB-H\fP|\fB\-\-cache\fP
 .ad b
 .br
 .ad l
-    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
+    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .ad b
 .br
 .ad l
-    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
+    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .ad b
 .br
 .ad l
-    \fB--cachepolicy\fP \fIString\fP
+    \fB\-\-cachepolicy\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--cachepool\fP \fILV\fP
+    \fB\-\-cachepool\fP \fILV\fP
 .ad b
 .br
 .ad l
-    \fB--cachesettings\fP \fIString\fP
+    \fB\-\-cachesettings\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
+ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
-    \fB--commandprofile\fP \fIString\fP
+    \fB\-\-commandprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--config\fP \fIString\fP
+    \fB\-\-config\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
+ \fB-C\fP|\fB\-\-contiguous\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-d\fP|\fB--debug\fP
+ \fB-d\fP|\fB\-\-debug\fP
 .ad b
 .br
 .ad l
-    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
+    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .ad b
 .br
 .ad l
-    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
+    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT]
+ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT]
 .ad b
 .br
 .ad l
- \fB-h\fP|\fB--help\fP
+ \fB-h\fP|\fB\-\-help\fP
 .ad b
 .br
 .ad l
- \fB-K\fP|\fB--ignoreactivationskip\fP
+ \fB-K\fP|\fB\-\-ignoreactivationskip\fP
 .ad b
 .br
 .ad l
-    \fB--ignoremonitoring\fP
+    \fB\-\-ignoremonitoring\fP
 .ad b
 .br
 .ad l
-    \fB--longhelp\fP
+    \fB\-\-longhelp\fP
 .ad b
 .br
 .ad l
- \fB-j\fP|\fB--major\fP \fINumber\fP
+ \fB-j\fP|\fB\-\-major\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
+    \fB\-\-[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
-    \fB--metadataprofile\fP \fIString\fP
+    \fB\-\-metadataprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--minor\fP \fINumber\fP
+    \fB\-\-minor\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
+    \fB\-\-[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
-    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
+    \fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .ad b
 .br
 .ad l
- \fB-m\fP|\fB--mirrors\fP \fINumber\fP
+ \fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--monitor\fP \fBy\fP|\fBn\fP
+    \fB\-\-monitor\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-n\fP|\fB--name\fP \fIString\fP
+ \fB-n\fP|\fB\-\-name\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--nosync\fP
+    \fB\-\-nosync\fP
 .ad b
 .br
 .ad l
-    \fB--noudevsync\fP
+    \fB\-\-noudevsync\fP
 .ad b
 .br
 .ad l
- \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
+ \fB-p\fP|\fB\-\-permission\fP \fBrw\fP|\fBr\fP
 .ad b
 .br
 .ad l
- \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
+ \fB-M\fP|\fB\-\-persistent\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
+    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
-    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
+    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--profile\fP \fIString\fP
+    \fB\-\-profile\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-q\fP|\fB--quiet\fP
+ \fB-q\fP|\fB\-\-quiet\fP
 .ad b
 .br
 .ad l
- \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
+ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .ad b
 .br
 .ad l
- \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
+ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .ad b
 .br
 .ad l
- \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
+ \fB-k\fP|\fB\-\-setactivationskip\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+ \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
- \fB-s\fP|\fB--snapshot\fP
+ \fB-s\fP|\fB\-\-snapshot\fP
 .ad b
 .br
 .ad l
- \fB-i\fP|\fB--stripes\fP \fINumber\fP
+ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP
 .ad b
 .br
 .ad l
- \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
+ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
- \fB-t\fP|\fB--test\fP
+ \fB-t\fP|\fB\-\-test\fP
 .ad b
 .br
 .ad l
- \fB-T\fP|\fB--thin\fP
+ \fB-T\fP|\fB\-\-thin\fP
 .ad b
 .br
 .ad l
-    \fB--thinpool\fP \fILV\fP
+    \fB\-\-thinpool\fP \fILV\fP
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+    \fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
 .ad b
 .br
 .ad l
- \fB-v\fP|\fB--verbose\fP
+ \fB-v\fP|\fB\-\-verbose\fP
 .ad b
 .br
 .ad l
-    \fB--version\fP
+    \fB\-\-version\fP
 .ad b
 .br
 .ad l
- \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+ \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
- \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP
+ \fB-W\fP|\fB\-\-wipesignatures\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-y\fP|\fB--yes\fP
+ \fB-y\fP|\fB\-\-yes\fP
 .ad b
 .br
 .ad l
- \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .ad b
 .SH DESCRIPTION
 lvcreate creates a new LV in a VG. For standard LVs, this requires
@@ -270,11 +270,11 @@ virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
 .SS Usage notes
-In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
+with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
 the options section.
 
-In the usage section below, \fB--name\fP is omitted from the required
+In the usage section below, \fB\-\-name\fP is omitted from the required
 options, even though it is typically used.  When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.  Also see the description in the options section.
@@ -282,15 +282,15 @@ numeric suffix.  Also see the description in the options section.
 Create a linear LV.
 .br
 .P
-\fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP ]
+[    \fB\-\-type\fP \fBlinear\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -301,18 +301,18 @@ Create a linear LV.
 .RE
 -
 
-Create a striped LV (infers --type striped).
+Create a striped LV (infers \-\-type striped).
 .br
 .P
-\fBlvcreate\fP \fB-i\fP|\fB--stripes\fP \fINumber\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -323,30 +323,30 @@ Create a striped LV (infers --type striped).
 .RE
 -
 
-Create a raid1 or mirror LV (infers --type raid1|mirror).
+Create a raid1 or mirror LV (infers \-\-type raid1|mirror).
 .br
 .P
-\fBlvcreate\fP \fB-m\fP|\fB--mirrors\fP \fINumber\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
+[    \fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
 .ad l
-[    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -360,35 +360,35 @@ Create a raid1 or mirror LV (infers --type raid1|mirror).
 Create a raid LV (a specific raid level must be used, e.g. raid1).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBraid\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBraid\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
+[ \fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -402,30 +402,30 @@ Create a raid LV (a specific raid level must be used, e.g. raid1).
 Create a raid10 LV.
 .br
 .P
-\fBlvcreate\fP \fB-m\fP|\fB--mirrors\fP \fINumber\fP \fB-i\fP|\fB--stripes\fP \fINumber\fP
+\fBlvcreate\fP \fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP
 .RS 5
- \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+ \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -439,27 +439,27 @@ Create a raid10 LV.
 Create a COW snapshot LV of an origin LV.
 .br
 .P
-\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP
+\fBlvcreate\fP \fB-s\fP|\fB\-\-snapshot\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBsnapshot\fP ]
+[    \fB\-\-type\fP \fBsnapshot\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -473,43 +473,43 @@ Create a COW snapshot LV of an origin LV.
 Create a thin pool.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin-pool\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBthin-pool\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--thinpool\fP \fILV\fP\fI_new\fP ]
+[    \fB\-\-thinpool\fP \fILV\fP\fI_new\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -523,43 +523,43 @@ Create a thin pool.
 Create a cache pool.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBcache-pool\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBcache-pool\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-H\fP|\fB--cache\fP ]
+[ \fB-H\fP|\fB\-\-cache\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -570,26 +570,26 @@ Create a cache pool.
 .RE
 -
 
-Create a thin LV in a thin pool (infers --type thin).
+Create a thin LV in a thin pool (infers \-\-type thin).
 .br
 .P
-\fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fIVG\fP
+\fBlvcreate\fP \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT] \fB\-\-thinpool\fP \fILV\fP\fI_thinpool\fP \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -599,22 +599,22 @@ Create a thin LV in a thin pool (infers --type thin).
 
 Create a thin LV that is a snapshot of an existing thin LV 
 .br
-(infers --type thin).
+(infers \-\-type thin).
 .br
 .P
-\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fILV\fP\fI_thin\fP
+\fBlvcreate\fP \fB-s\fP|\fB\-\-snapshot\fP \fILV\fP\fI_thin\fP
 .br
 .RS 4
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -625,31 +625,31 @@ Create a thin LV that is a snapshot of an existing thin LV
 Create a thin LV that is a snapshot of an external origin LV.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fILV\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBthin\fP \fB\-\-thinpool\fP \fILV\fP\fI_thinpool\fP \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -659,49 +659,49 @@ Create a thin LV that is a snapshot of an external origin LV.
 
 Create a thin LV, first creating a thin pool for it, 
 .br
-where the new thin pool is named by the --thinpool arg.
+where the new thin pool is named by the \-\-thinpool arg.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB\-\-type\fP \fBthin\fP \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_new\fP
+ \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fB\-\-thinpool\fP \fILV\fP\fI_new\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -716,57 +716,57 @@ Create a cache LV, first creating a new origin LV,
 .br
 then combining it with the existing cache pool named 
 .br
-by the --cachepool arg.
+by the \-\-cachepool arg.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB\-\-type\fP \fBcache\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB--cachepool\fP \fILV\fP\fI_cachepool\fP \fIVG\fP
+ \fB\-\-cachepool\fP \fILV\fP\fI_cachepool\fP \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-H\fP|\fB--cache\fP ]
+[ \fB-H\fP|\fB\-\-cache\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -781,87 +781,87 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+[ \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+[ \fB-C\fP|\fB\-\-contiguous\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+[ \fB-K\fP|\fB\-\-ignoreactivationskip\fP ]
 .ad b
 .br
 .ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+[ \fB-j\fP|\fB\-\-major\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+[ \fB-n\fP|\fB\-\-name\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+[ \fB-p\fP|\fB\-\-permission\fP \fBrw\fP|\fBr\fP ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+[ \fB-M\fP|\fB\-\-persistent\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[ \fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+[ \fB-k\fP|\fB\-\-setactivationskip\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+[ \fB-W\fP|\fB\-\-wipesignatures\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--addtag\fP \fITag\fP ]
+[    \fB\-\-addtag\fP \fITag\fP ]
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoremonitoring\fP ]
+[    \fB\-\-ignoremonitoring\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--minor\fP \fINumber\fP ]
+[    \fB\-\-minor\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-monitor\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosync\fP ]
+[    \fB\-\-nosync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -869,57 +869,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+\fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
 Controls the active state of the new LV.
 \fBy\fP makes the LV active, or available.
@@ -928,23 +928,23 @@ New LVs are made active by default.
 In some cases, creating an LV requires it to be active.
 For example, COW snapshots of an active origin LV can only
 be created in the active state (this does not apply to thin snapshots.)
-The --zero option normally requires the LV to be active.
+The \-\-zero option normally requires the LV to be active.
 If autoactivation \fBay\fP is used, the LV is only activated
 if it matches an item in lvm.conf activation/auto_activation_volume_list.
-\fBay\fP implies --zero n and --wipesignatures n.
+\fBay\fP implies \-\-zero n and \-\-wipesignatures n.
 See lvmlockd(8) for more information about activation options for shared VGs.
 See clvmd(8) for more information about activation options for clustered VGs.
 .ad b
 .HP
 .ad l
-\fB--addtag\fP \fITag\fP
+\fB\-\-addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -965,28 +965,28 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB-H\fP|\fB--cache\fP
+\fB-H\fP|\fB\-\-cache\fP
 .br
 Specifies the command is handling a cache LV or cache pool.
-See --type cache and --type cache-pool.
+See \-\-type cache and \-\-type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
 .ad b
 .HP
 .ad l
-\fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
+\fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
 Specifies the cache metadata format used by cache target.
 .ad b
 .HP
 .ad l
-\fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
+\fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
@@ -1002,20 +1002,20 @@ block invalidates. See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--cachepolicy\fP \fIString\fP
+\fB\-\-cachepolicy\fP \fIString\fP
 .br
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--cachepool\fP \fILV\fP
+\fB\-\-cachepool\fP \fILV\fP
 .br
 The name of a cache pool LV.
 .ad b
 .HP
 .ad l
-\fB--cachesettings\fP \fIString\fP
+\fB\-\-cachesettings\fP \fIString\fP
 .br
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
@@ -1027,7 +1027,7 @@ See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
+\fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT]
 .br
 The size of chunks in a snapshot, cache pool or thin pool.
 For snapshots, the value must be a power of 2 between 4KiB and 512KiB
@@ -1042,14 +1042,14 @@ See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -1058,7 +1058,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
+\fB-C\fP|\fB\-\-contiguous\fP \fBy\fP|\fBn\fP
 .br
 Sets or resets the contiguous allocation policy for LVs.
 Default is no contiguous allocation based on a next free principle.
@@ -1068,14 +1068,14 @@ are already contiguous.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
+\fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
@@ -1088,14 +1088,14 @@ See \fBlvmthin\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--errorwhenfull\fP \fBy\fP|\fBn\fP
+\fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
 Specifies thin pool behavior when data space is exhausted.
 When yes, device-mapper will immediately return an error
@@ -1108,10 +1108,10 @@ See \fBlvmthin\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT]
+\fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT]
 .br
 Specifies the size of the new LV in logical extents.
-The --size and --extents options are alternate methods of specifying size.
+The \-\-size and \-\-extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 An alternate syntax allows the size to be determined indirectly
@@ -1128,39 +1128,39 @@ extents in the new LV is not determined until the command has completed.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-K\fP|\fB--ignoreactivationskip\fP
+\fB-K\fP|\fB\-\-ignoreactivationskip\fP
 .br
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
 .ad b
 .HP
 .ad l
-\fB--ignoremonitoring\fP
+\fB\-\-ignoremonitoring\fP
 .br
-Do not interact with dmeventd unless --monitor is specified.
+Do not interact with dmeventd unless \-\-monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-j\fP|\fB--major\fP \fINumber\fP
+\fB-j\fP|\fB\-\-major\fP \fINumber\fP
 .br
 Sets the major number of an LV block device.
 .ad b
 .HP
 .ad l
-\fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
+\fB\-\-[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
 Sets the maximum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
@@ -1169,20 +1169,20 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--metadataprofile\fP \fIString\fP
+\fB\-\-metadataprofile\fP \fIString\fP
 .br
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--minor\fP \fINumber\fP
+\fB\-\-minor\fP \fINumber\fP
 .br
 Sets the minor number of an LV block device.
 .ad b
 .HP
 .ad l
-\fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
+\fB\-\-[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
 Sets the minimum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
@@ -1191,7 +1191,7 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
+\fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .br
 Specifies the type of mirror log for LVs with the "mirror" type
 (does not apply to the "raid1" type.)
@@ -1204,25 +1204,25 @@ the first device to others) each time the LV is activated, e.g. after reboot.
 .ad b
 .HP
 .ad l
-\fB-m\fP|\fB--mirrors\fP \fINumber\fP
+\fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP
 .br
 Specifies the number of mirror images in addition to the original LV
-image, e.g. --mirrors 1 means there are two images of the data, the
+image, e.g. \-\-mirrors 1 means there are two images of the data, the
 original and one mirror image.
 Optional positional PV args on the command line can specify the devices
 the images should be placed on.
 There are two mirroring implementations: "raid1" and "mirror".
 These are the names of the corresponding LV types, or "segment types".
-Use the --type option to specify which to use (raid1 is default,
+Use the \-\-type option to specify which to use (raid1 is default,
 and mirror is legacy)
 Use lvm.conf global/mirror_segtype_default and
 global/raid10_segtype_default to configure the default types.
-See the --nosync option for avoiding initial image synchronization.
+See the \-\-nosync option for avoiding initial image synchronization.
 See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--monitor\fP \fBy\fP|\fBn\fP
+\fB\-\-monitor\fP \fBy\fP|\fBn\fP
 .br
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
@@ -1231,7 +1231,7 @@ See dmeventd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB-n\fP|\fB--name\fP \fIString\fP
+\fB-n\fP|\fB\-\-name\fP \fIString\fP
 .br
 Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
@@ -1239,7 +1239,7 @@ generated, where # is a number generated by LVM.
 .ad b
 .HP
 .ad l
-\fB--nosync\fP
+\fB\-\-nosync\fP
 .br
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
@@ -1256,7 +1256,7 @@ and thus do not support initial synchronization.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -1265,25 +1265,25 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
+\fB-p\fP|\fB\-\-permission\fP \fBrw\fP|\fBr\fP
 .br
 Set access permission to read only \fBr\fP or read and write \fBrw\fP.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
+\fB-M\fP|\fB\-\-persistent\fP \fBy\fP|\fBn\fP
 .br
 When yes, makes the specified minor number persistent.
 .ad b
 .HP
 .ad l
-\fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
+\fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
 Specifies the size of the new pool metadata LV.
 .ad b
 .HP
 .ad l
-\fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
+\fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP
 .br
 Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
@@ -1291,21 +1291,21 @@ space that can be used when repairing a pool.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
+\fB-r\fP|\fB\-\-readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
@@ -1314,7 +1314,7 @@ a suitable value automatically.
 .ad b
 .HP
 .ad l
-\fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
+\fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT]
 .br
 Size of each raid or mirror synchronization region.
 lvm.conf activation/raid_region_size can be used to
@@ -1322,7 +1322,7 @@ configure a default.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -1333,27 +1333,27 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
+\fB-k\fP|\fB\-\-setactivationskip\fP \fBy\fP|\fBn\fP
 .br
 Persistently sets (yes) or clears (no) the "activation skip" flag on an LV.
 An LV with this flag set is not activated unless the
---ignoreactivationskip option is used by the activation command.
+\-\-ignoreactivationskip option is used by the activation command.
 This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
 .ad b
 .HP
 .ad l
-\fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+\fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT]
 .br
 Specifies the size of the new LV.
-The --size and --extents options are alternate methods of specifying size.
+The \-\-size and \-\-extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 .ad b
 .HP
 .ad l
-\fB-s\fP|\fB--snapshot\fP
+\fB-s\fP|\fB\-\-snapshot\fP
 .br
 Create a snapshot. Snapshots provide a "frozen image" of an origin LV.
 The snapshot LV can be used, e.g. for backups, while the origin LV
@@ -1364,7 +1364,7 @@ Thin snapshots are created when the origin is a thin LV and
 the size option is NOT specified. Thin snapshots share the same blocks
 in the thin pool, and do not allocate new space from the VG.
 Thin snapshots are created with the "activation skip" flag,
-see --setactivationskip.
+see \-\-setactivationskip.
 A thin snapshot of a non-thin "external origin" LV is created
 when a thin pool is specified. Unprovisioned blocks in the thin snapshot
 LV are read from the external origin LV. The external origin LV must
@@ -1378,17 +1378,17 @@ often 20% of the origin LV is enough. If COW space runs low, it can
 be extended with lvextend (shrinking is also allowed with lvreduce.)
 A small amount of the COW snapshot LV size is used to track COW block
 locations, so the full size is not available for COW data blocks.
-Use lvs to check how much space is used, and see --monitor to
+Use lvs to check how much space is used, and see \-\-monitor to
 to automatically extend the size to avoid running out of space.
 .ad b
 .HP
 .ad l
-\fB-i\fP|\fB--stripes\fP \fINumber\fP
+\fB-i\fP|\fB\-\-stripes\fP \fINumber\fP
 .br
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
-the stripe size (see --stripesize). This does not change existing
+the stripe size (see \-\-stripesize). This does not change existing
 allocated space, but only applies to space being allocated by the command.
 When creating a RAID 4/5/6 LV, this number does not include the extra
 devices that are required for parity. The largest number depends on
@@ -1400,14 +1400,14 @@ see lvm.conf allocation/raid_stripe_all_devices.
 .ad b
 .HP
 .ad l
-\fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
+\fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT]
 .br
 The amount of data that is written to one device before
 moving to the next in a striped LV.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -1417,21 +1417,21 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-T\fP|\fB--thin\fP
+\fB-T\fP|\fB\-\-thin\fP
 .br
 Specifies the command is handling a thin LV or thin pool.
-See --type thin, --type thin-pool, and --virtualsize.
+See \-\-type thin, \-\-type thin-pool, and \-\-virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
 .ad b
 .HP
 .ad l
-\fB--thinpool\fP \fILV\fP
+\fB\-\-thinpool\fP \fILV\fP
 .br
 The name of a thin pool LV.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+\fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
@@ -1441,25 +1441,25 @@ For performance caching (\fBcache\fP, \fBcache-pool\fP) see \fBlvmcache\fP(7).
 For copy-on-write snapshots (\fBsnapshot\fP) see usage definitions.
 Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
-(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
+(e.g. \-\-stripes, \-\-mirrors, \-\-snapshot, \-\-virtualsize, \-\-thin, \-\-cache).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+\fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT]
 .br
 The virtual size of a new thin LV.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
@@ -1476,13 +1476,13 @@ large sparse LVs (GiB).
 .ad b
 .HP
 .ad l
-\fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP
+\fB-W\fP|\fB\-\-wipesignatures\fP \fBy\fP|\fBn\fP
 .br
 Controls detection and subsequent wiping of signatures on new LVs.
 There is a prompt for each signature detected to confirm its wiping
-(unless --yes is used to override confirmations.)
+(unless \-\-yes is used to override confirmations.)
 When not specified, signatures are wiped whenever zeroing is done
-(see --zero). This behaviour can be configured with
+(see \-\-zero). This behaviour can be configured with
 lvm.conf allocation/wipe_signatures_when_zeroing_new_lvs.
 If blkid wiping is used (lvm.conf allocation/use_blkid_wiping)
 and LVM is compiled with blkid wiping support, then the blkid(8)
@@ -1494,7 +1494,7 @@ The LV is not wiped if the read only flag is set.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -1502,7 +1502,7 @@ answer yes. Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+\fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .br
 Controls zeroing of the first 4KiB of data in the new LV.
 Default is \fBy\fP.
@@ -1517,7 +1517,7 @@ Warning: trying to mount an unzeroed LV can cause the system to hang.
 Volume Group name.  See \fBlvm\fP(8) for valid names.
 For lvcreate, the required VG positional arg may be
 omitted when the VG name is included in another option,
-e.g. --name VG/LV.
+e.g. \-\-name VG/LV.
 .HP
 \fILV\fP
 .br
@@ -1550,7 +1550,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
@@ -1561,11 +1561,11 @@ Alternate command forms, advanced command usage, and listing of all valid syntax
 Create an LV that returns errors when used.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBerror\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBerror\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1576,11 +1576,11 @@ Create an LV that returns errors when used.
 Create an LV that returns zeros when read.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBzero\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBzero\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1591,11 +1591,11 @@ Create an LV that returns zeros when read.
 Create a linear LV.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBlinear\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBlinear\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1606,22 +1606,22 @@ Create a linear LV.
 .RE
 -
 
-Create a striped LV (also see lvcreate --stripes).
+Create a striped LV (also see lvcreate \-\-stripes).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBstriped\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBstriped\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1632,34 +1632,34 @@ Create a striped LV (also see lvcreate --stripes).
 .RE
 -
 
-Create a mirror LV (also see --type raid1).
+Create a mirror LV (also see \-\-type raid1).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBmirror\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBmirror\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
+[ \fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-R\fP|\fB\-\-regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
+[    \fB\-\-mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1672,30 +1672,30 @@ Create a mirror LV (also see --type raid1).
 
 Create a COW snapshot LV of an origin LV 
 .br
-(also see --snapshot).
+(also see \-\-snapshot).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBsnapshot\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBsnapshot\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-s\fP|\fB--snapshot\fP ]
+[ \fB-s\fP|\fB\-\-snapshot\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1708,25 +1708,25 @@ Create a COW snapshot LV of an origin LV
 
 Create a sparse COW snapshot LV of a virtual origin LV 
 .br
-(also see --snapshot).
+(also see \-\-snapshot).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBsnapshot\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB\-\-type\fP \fBsnapshot\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
+ \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-s\fP|\fB--snapshot\fP ]
+[ \fB-s\fP|\fB\-\-snapshot\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1740,22 +1740,22 @@ Create a sparse COW snapshot LV of a virtual origin LV
 Create a sparse COW snapshot LV of a virtual origin LV.
 .br
 .P
-\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB-s\fP|\fB\-\-snapshot\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
+ \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBsnapshot\fP ]
+[    \fB\-\-type\fP \fBsnapshot\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1766,46 +1766,46 @@ Create a sparse COW snapshot LV of a virtual origin LV.
 .RE
 -
 
-Create a thin pool (infers --type thin-pool).
+Create a thin pool (infers \-\-type thin-pool).
 .br
 .P
-\fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB-T\fP|\fB\-\-thin\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin-pool\fP ]
+[    \fB\-\-type\fP \fBthin-pool\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1816,52 +1816,52 @@ Create a thin pool (infers --type thin-pool).
 .RE
 -
 
-Create a thin pool named by the --thinpool arg 
+Create a thin pool named by the \-\-thinpool arg 
 .br
-(infers --type thin-pool).
+(infers \-\-type thin-pool).
 .br
 .P
-\fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_new\fP \fIVG\fP
+\fBlvcreate\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fB\-\-thinpool\fP \fILV\fP\fI_new\fP \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin-pool\fP ]
+[    \fB\-\-type\fP \fBthin-pool\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1872,51 +1872,51 @@ Create a thin pool named by the --thinpool arg
 .RE
 -
 
-Create a cache pool named by the --cachepool arg 
+Create a cache pool named by the \-\-cachepool arg 
 .br
-(variant, uses --cachepool in place of --name).
+(variant, uses \-\-cachepool in place of \-\-name).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBcache-pool\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB\-\-type\fP \fBcache-pool\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB--cachepool\fP \fILV\fP\fI_new\fP \fIVG\fP
+ \fB\-\-cachepool\fP \fILV\fP\fI_new\fP \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-H\fP|\fB--cache\fP ]
+[ \fB-H\fP|\fB\-\-cache\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1930,34 +1930,34 @@ Create a cache pool named by the --cachepool arg
 Create a thin LV in a thin pool.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB\-\-type\fP \fBthin\fP \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fIVG\fP
+ \fB\-\-thinpool\fP \fILV\fP\fI_thinpool\fP \fIVG\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1967,22 +1967,22 @@ Create a thin LV in a thin pool.
 
 Create a thin LV in a thin pool named in the first arg 
 .br
-(variant, also see --thinpool for naming pool).
+(variant, also see \-\-thinpool for naming pool).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBthin\fP \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -1992,28 +1992,28 @@ Create a thin LV in a thin pool named in the first arg
 
 Create a thin LV in the thin pool named in the first arg 
 .br
-(variant, infers --type thin, also see --thinpool for 
+(variant, infers \-\-type thin, also see \-\-thinpool for 
 .br
 naming pool.)
 .br
 .P
-\fBlvcreate\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
+\fBlvcreate\fP \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2024,19 +2024,19 @@ naming pool.)
 Create a thin LV that is a snapshot of an existing thin LV.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fILV\fP\fI_thin\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBthin\fP \fILV\fP\fI_thin\fP
 .br
 .RS 4
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2046,22 +2046,22 @@ Create a thin LV that is a snapshot of an existing thin LV.
 
 Create a thin LV that is a snapshot of an existing thin LV 
 .br
-(infers --type thin).
+(infers \-\-type thin).
 .br
 .P
-\fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fILV\fP\fI_thin\fP
+\fBlvcreate\fP \fB-T\fP|\fB\-\-thin\fP \fILV\fP\fI_thin\fP
 .br
 .RS 4
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2071,22 +2071,22 @@ Create a thin LV that is a snapshot of an existing thin LV
 
 Create a thin LV that is a snapshot of an external origin LV 
 .br
-(infers --type thin).
+(infers \-\-type thin).
 .br
 .P
-\fBlvcreate\fP \fB-s\fP|\fB--snapshot\fP \fB--thinpool\fP \fILV\fP\fI_thinpool\fP \fILV\fP
+\fBlvcreate\fP \fB-s\fP|\fB\-\-snapshot\fP \fB\-\-thinpool\fP \fILV\fP\fI_thinpool\fP \fILV\fP
 .br
 .RS 4
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2096,51 +2096,51 @@ Create a thin LV that is a snapshot of an external origin LV
 
 Create a thin LV, first creating a thin pool for it, 
 .br
-where the new thin pool is named by the --thinpool arg 
+where the new thin pool is named by the \-\-thinpool arg 
 .br
-(variant, infers --type thin).
+(variant, infers \-\-type thin).
 .br
 .P
-\fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB-T\fP|\fB\-\-thin\fP \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--thinpool\fP \fILV\fP\fI_new\fP
+ \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fB\-\-thinpool\fP \fILV\fP\fI_new\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2160,46 +2160,46 @@ or the new thin pool name is generated when the first
 arg is a VG name.
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBthin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB\-\-type\fP \fBthin\fP \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP|\fILV\fP\fI_new\fP
+ \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP|\fILV\fP\fI_new\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2216,49 +2216,49 @@ where the new thin pool is named in the first arg,
 .br
 or the new thin pool name is generated when the first 
 .br
-arg is a VG name (variant, infers --type thin).
+arg is a VG name (variant, infers \-\-type thin).
 .br
 .P
-\fBlvcreate\fP \fB-T\fP|\fB--thin\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+\fBlvcreate\fP \fB-T\fP|\fB\-\-thin\fP \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT]
 .RS 5
- \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP|\fILV\fP\fI_new\fP
+ \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fIVG\fP|\fILV\fP\fI_new\fP
 .RE
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2271,62 +2271,62 @@ arg is a VG name (variant, infers --type thin).
 
 Create a thin LV, first creating a thin pool for it 
 .br
-(infers --type thin). 
+(infers \-\-type thin). 
 .br
 Create a sparse snapshot of a virtual origin LV 
 .br
-(infers --type snapshot). 
+(infers \-\-type snapshot). 
 .br
-Chooses --type thin or --type snapshot according to 
+Chooses \-\-type thin or \-\-type snapshot according to 
 .br
 config setting sparse_segtype_default.
 .br
 .P
-\fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
+\fBlvcreate\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fB-V\fP|\fB\-\-virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-T\fP|\fB--thin\fP ]
+[ \fB-T\fP|\fB\-\-thin\fP ]
 .ad b
 .br
 .ad l
-[ \fB-s\fP|\fB--snapshot\fP ]
+[ \fB-s\fP|\fB\-\-snapshot\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBthin\fP ]
+[    \fB\-\-type\fP \fBthin\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
+[    \fB\-\-discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
 .ad l
-[    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2341,50 +2341,50 @@ Create a cache LV, first creating a new origin LV,
 .br
 then combining it with the existing cache pool named 
 .br
-by the --cachepool arg (variant, infers --type cache).
+by the \-\-cachepool arg (variant, infers \-\-type cache).
 .br
 .P
-\fBlvcreate\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fB--cachepool\fP \fILV\fP\fI_cachepool\fP \fIVG\fP
+\fBlvcreate\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fB\-\-cachepool\fP \fILV\fP\fI_cachepool\fP \fIVG\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-H\fP|\fB--cache\fP ]
+[ \fB-H\fP|\fB\-\-cache\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBcache\fP ]
+[    \fB\-\-type\fP \fBcache\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2399,54 +2399,54 @@ Create a cache LV, first creating a new origin LV,
 .br
 then combining it with the existing cache pool named 
 .br
-in the first arg (variant, also use --cachepool).
+in the first arg (variant, also use \-\-cachepool).
 .br
 .P
-\fBlvcreate\fP \fB--type\fP \fBcache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP\fI_cachepool\fP
+\fBlvcreate\fP \fB\-\-type\fP \fBcache\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fILV\fP\fI_cachepool\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-H\fP|\fB--cache\fP ]
+[ \fB-H\fP|\fB\-\-cache\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -2463,7 +2463,7 @@ first creating a new origin LV, then combining it with
 .br
 the existing cache pool named in the first arg 
 .br
-(variant, infers --type cache, also use --cachepool). 
+(variant, infers \-\-type cache, also use \-\-cachepool). 
 .br
 When LV is not a cache pool, convert the specified LV 
 .br
@@ -2472,47 +2472,47 @@ to type cache after creating a new cache pool LV to use
 (use lvconvert).
 .br
 .P
-\fBlvcreate\fP \fB-H\fP|\fB--cache\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fILV\fP
+\fBlvcreate\fP \fB-H\fP|\fB\-\-cache\fP \fB-L\fP|\fB\-\-size\fP \fISize\fP[m|UNIT] \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+[ \fB-c\fP|\fB\-\-chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[    \fB\-\-cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[    \fB\-\-cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[    \fB\-\-cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index ff15df0..5aeb861 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -20,103 +20,103 @@ and more, using a more compact and configurable output format.
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--all\fP ]
+[ \fB-a\fP|\fB\-\-all\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--colon\fP ]
+[ \fB-c\fP|\fB\-\-colon\fP ]
 .ad b
 .br
 .ad l
-[ \fB-C\fP|\fB--columns\fP ]
+[ \fB-C\fP|\fB\-\-columns\fP ]
 .ad b
 .br
 .ad l
-[ \fB-H\fP|\fB--history\fP ]
+[ \fB-H\fP|\fB\-\-history\fP ]
 .ad b
 .br
 .ad l
-[ \fB-m\fP|\fB--maps\fP ]
+[ \fB-m\fP|\fB\-\-maps\fP ]
 .ad b
 .br
 .ad l
-[ \fB-o\fP|\fB--options\fP \fIString\fP ]
+[ \fB-o\fP|\fB\-\-options\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-O\fP|\fB--sort\fP \fIString\fP ]
+[ \fB-O\fP|\fB\-\-sort\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--aligned\fP ]
+[    \fB\-\-aligned\fP ]
 .ad b
 .br
 .ad l
-[    \fB--binary\fP ]
+[    \fB\-\-binary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
+[    \fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
 .ad b
 .br
 .ad l
-[    \fB--foreign\fP ]
+[    \fB\-\-foreign\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--logonly\fP ]
+[    \fB\-\-logonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noheadings\fP ]
+[    \fB\-\-noheadings\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosuffix\fP ]
+[    \fB\-\-nosuffix\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--segments\fP ]
+[    \fB\-\-segments\fP ]
 .ad b
 .br
 .ad l
-[    \fB--separator\fP \fIString\fP ]
+[    \fB\-\-separator\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--shared\fP ]
+[    \fB\-\-shared\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unbuffered\fP ]
+[    \fB\-\-unbuffered\fP ]
 .ad b
 .br
 .ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
+[    \fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -130,63 +130,63 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--aligned\fP
+\fB\-\-aligned\fP
 .br
-Use with --separator to align the output columns
+Use with \-\-separator to align the output columns
 .ad b
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
@@ -194,7 +194,7 @@ which are not independently accessible, e.g. not mountable.
 .ad b
 .HP
 .ad l
-\fB--binary\fP
+\fB\-\-binary\fP
 .br
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
@@ -202,28 +202,28 @@ the "unknown" value which denotes that the value could not be determined).
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--colon\fP
+\fB-c\fP|\fB\-\-colon\fP
 .br
 Generate colon separated output for easier parsing in scripts or programs.
 Also see vgs(8) which provides considerably more control over the output.
 .ad b
 .HP
 .ad l
-\fB-C\fP|\fB--columns\fP
+\fB-C\fP|\fB\-\-columns\fP
 .br
 Display output in columns, the equivalent of vgs(8).
 Options listed are the same as options given in vgs(8).
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -232,40 +232,40 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
+\fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--foreign\fP
+\fB\-\-foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-H\fP|\fB--history\fP
+\fB-H\fP|\fB\-\-history\fP
 .br
 Include historical LVs in the output.
 (This has no effect unless LVs were removed while
@@ -273,55 +273,55 @@ lvm.conf metadata/record_lvs_history was enabled.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--logonly\fP
+\fB\-\-logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-m\fP|\fB--maps\fP
+\fB-m\fP|\fB\-\-maps\fP
 .br
 Display the mapping of logical extents to PVs and physical extents.
 To map physical extents to logical extents use:
-pvs --segments -o+lv_name,seg_start_pe,segtype
+pvs \-\-segments -o+lv_name,seg_start_pe,segtype
 .ad b
 .HP
 .ad l
-\fB--noheadings\fP
+\fB\-\-noheadings\fP
 .br
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--nosuffix\fP
+\fB\-\-nosuffix\fP
 .br
-Suppress the suffix on output sizes. Use with --units
+Suppress the suffix on output sizes. Use with \-\-units
 (except h and H) if processing the output.
 .ad b
 .HP
 .ad l
-\fB-o\fP|\fB--options\fP \fIString\fP
+\fB-o\fP|\fB\-\-options\fP \fIString\fP
 .br
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
@@ -343,7 +343,7 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -352,21 +352,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -380,7 +380,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -391,17 +391,17 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--segments\fP
+\fB\-\-segments\fP
 .br
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -409,13 +409,13 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB--separator\fP \fIString\fP
+\fB\-\-separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--shared\fP
+\fB\-\-shared\fP
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
@@ -423,14 +423,14 @@ See lvmlockd(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
-\fB-O\fP|\fB--sort\fP \fIString\fP
+\fB-O\fP|\fB\-\-sort\fP \fIString\fP
 .br
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -440,37 +440,37 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--unbuffered\fP
+\fB\-\-unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
+\fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
-Custom units can be specified, e.g. --units 3M.
+Custom units can be specified, e.g. \-\-units 3M.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -506,7 +506,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvextend.8_des b/man/lvextend.8_des
index 4c0575d..f1e02d6 100644
--- a/man/lvextend.8_des
+++ b/man/lvextend.8_des
@@ -7,6 +7,6 @@ Extending a copy\-on\-write snapshot LV adds space for COW blocks.
 Use \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
 
-In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
+with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index b81cad3..0af58ad 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -11,115 +11,115 @@ lvextend \- Add space to a logical volume
 .br
 .P
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
 .br
 .ad l
- \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--commandprofile\fP \fIString\fP
+    \fB\-\-commandprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--config\fP \fIString\fP
+    \fB\-\-config\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-d\fP|\fB--debug\fP
+ \fB-d\fP|\fB\-\-debug\fP
 .ad b
 .br
 .ad l
-    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
+ \fB-l\fP|\fB\-\-extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
 .ad b
 .br
 .ad l
- \fB-f\fP|\fB--force\fP
+ \fB-f\fP|\fB\-\-force\fP
 .ad b
 .br
 .ad l
- \fB-h\fP|\fB--help\fP
+ \fB-h\fP|\fB\-\-help\fP
 .ad b
 .br
 .ad l
-    \fB--longhelp\fP
+    \fB\-\-longhelp\fP
 .ad b
 .br
 .ad l
- \fB-m\fP|\fB--mirrors\fP \fINumber\fP
+ \fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP
 .ad b
 .br
 .ad l
- \fB-n\fP|\fB--nofsck\fP
+ \fB-n\fP|\fB\-\-nofsck\fP
 .ad b
 .br
 .ad l
-    \fB--nosync\fP
+    \fB\-\-nosync\fP
 .ad b
 .br
 .ad l
-    \fB--noudevsync\fP
+    \fB\-\-noudevsync\fP
 .ad b
 .br
 .ad l
-    \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
+    \fB\-\-poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
-    \fB--profile\fP \fIString\fP
+    \fB\-\-profile\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-q\fP|\fB--quiet\fP
+ \fB-q\fP|\fB\-\-quiet\fP
 .ad b
 .br
 .ad l
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .ad b
 .br
 .ad l
- \fB-r\fP|\fB--resizefs\fP
+ \fB-r\fP|\fB\-\-resizefs\fP
 .ad b
 .br
 .ad l
- \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
+ \fB-L\fP|\fB\-\-size\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
- \fB-i\fP|\fB--stripes\fP \fINumber\fP
+ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP
 .ad b
 .br
 .ad l
- \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
+ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
- \fB-t\fP|\fB--test\fP
+ \fB-t\fP|\fB\-\-test\fP
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+    \fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
 .ad b
 .br
 .ad l
-    \fB--usepolicies\fP
+    \fB\-\-usepolicies\fP
 .ad b
 .br
 .ad l
- \fB-v\fP|\fB--verbose\fP
+ \fB-v\fP|\fB\-\-verbose\fP
 .ad b
 .br
 .ad l
-    \fB--version\fP
+    \fB\-\-version\fP
 .ad b
 .br
 .ad l
- \fB-y\fP|\fB--yes\fP
+ \fB-y\fP|\fB\-\-yes\fP
 .ad b
 .SH DESCRIPTION
 lvextend extends the size of an LV. This requires allocating logical
@@ -131,34 +131,34 @@ Extending a copy\-on\-write snapshot LV adds space for COW blocks.
 Use \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
 
-In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
+with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
 the options section.
 .SH USAGE
 Extend an LV by a specified size.
 .br
 .P
-\fBlvextend\fP \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV\fP
+\fBlvextend\fP \fB-L\fP|\fB\-\-size\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP [\fB+\fP]\fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--resizefs\fP ]
+[ \fB-r\fP|\fB\-\-resizefs\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -176,15 +176,15 @@ Extend an LV by specified PV extents.
 .br
 .RS 4
 .ad l
-[ \fB-r\fP|\fB--resizefs\fP ]
+[ \fB-r\fP|\fB\-\-resizefs\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -195,15 +195,15 @@ Extend an LV by specified PV extents.
 Extend a pool metadata SubLV by a specified size.
 .br
 .P
-\fBlvextend\fP \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
+\fBlvextend\fP \fB\-\-poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
 .br
 .RS 4
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -217,11 +217,11 @@ Extend a pool metadata SubLV by a specified size.
 Extend an LV according to a predefined policy.
 .br
 .P
-\fBlvextend\fP \fB--usepolicies\fP \fILV\fP\fI_snapshot_thinpool\fP
+\fBlvextend\fP \fB\-\-usepolicies\fP \fILV\fP\fI_snapshot_thinpool\fP
 .br
 .RS 4
 .ad l
-[ \fB-r\fP|\fB--resizefs\fP ]
+[ \fB-r\fP|\fB\-\-resizefs\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -236,39 +236,39 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
+[ \fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-n\fP|\fB--nofsck\fP ]
+[ \fB-n\fP|\fB\-\-nofsck\fP ]
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosync\fP ]
+[    \fB\-\-nosync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP ]
+[    \fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP ]
 .ad b
 .RE
 
@@ -276,57 +276,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -347,21 +347,21 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -370,24 +370,24 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
+\fB-l\fP|\fB\-\-extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
 .br
 Specifies the new size of the LV in logical extents.
-The --size and --extents options are alternate methods of specifying size.
+The \-\-size and \-\-extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 An alternate syntax allows the size to be determined indirectly
@@ -407,40 +407,40 @@ from the current size.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-m\fP|\fB--mirrors\fP \fINumber\fP
+\fB-m\fP|\fB\-\-mirrors\fP \fINumber\fP
 .br
 Not used.
 .ad b
 .HP
 .ad l
-\fB-n\fP|\fB--nofsck\fP
+\fB-n\fP|\fB\-\-nofsck\fP
 .br
 Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use --force to proceed with
+requires it. You may need to use \-\-force to proceed with
 this option.
 .ad b
 .HP
 .ad l
-\fB--nosync\fP
+\fB\-\-nosync\fP
 .br
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
@@ -457,7 +457,7 @@ and thus do not support initial synchronization.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -466,7 +466,7 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
+\fB\-\-poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
 Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
@@ -474,21 +474,21 @@ the value is added to the current size.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -499,16 +499,16 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-r\fP|\fB--resizefs\fP
+\fB-r\fP|\fB\-\-resizefs\fP
 .br
 Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
 .HP
 .ad l
-\fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
+\fB-L\fP|\fB\-\-size\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
 Specifies the new size of the LV.
-The --size and --extents options are alternate methods of specifying size.
+The \-\-size and \-\-extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
@@ -517,12 +517,12 @@ from the current size.
 .ad b
 .HP
 .ad l
-\fB-i\fP|\fB--stripes\fP \fINumber\fP
+\fB-i\fP|\fB\-\-stripes\fP \fINumber\fP
 .br
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
-the stripe size (see --stripesize). This does not change existing
+the stripe size (see \-\-stripesize). This does not change existing
 allocated space, but only applies to space being allocated by the command.
 When creating a RAID 4/5/6 LV, this number does not include the extra
 devices that are required for parity. The largest number depends on
@@ -534,14 +534,14 @@ see lvm.conf allocation/raid_stripe_all_devices.
 .ad b
 .HP
 .ad l
-\fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
+\fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT]
 .br
 The amount of data that is written to one device before
 moving to the next in a striped LV.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -551,7 +551,7 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+\fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
@@ -561,32 +561,32 @@ For performance caching (\fBcache\fP, \fBcache-pool\fP) see \fBlvmcache\fP(7).
 For copy-on-write snapshots (\fBsnapshot\fP) see usage definitions.
 Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
-(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
+(e.g. \-\-stripes, \-\-mirrors, \-\-snapshot, \-\-virtualsize, \-\-thin, \-\-cache).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP
 .ad l
-\fB--usepolicies\fP
+\fB\-\-usepolicies\fP
 .br
 Perform an operation according to the policy configured in lvm.conf
 or a profile.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -625,7 +625,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvm-config.8_pregen b/man/lvm-config.8_pregen
index 6c02ed8..a1aafbf 100644
--- a/man/lvm-config.8_pregen
+++ b/man/lvm-config.8_pregen
@@ -20,75 +20,75 @@ line settings from \-\-config.
 .br
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--file\fP \fIString\fP ]
+[ \fB-f\fP|\fB\-\-file\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-l\fP|\fB--list\fP ]
+[ \fB-l\fP|\fB\-\-list\fP ]
 .ad b
 .br
 .ad l
-[    \fB--atversion\fP \fIString\fP ]
+[    \fB\-\-atversion\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
+[    \fB\-\-typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreadvanced\fP ]
+[    \fB\-\-ignoreadvanced\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreunsupported\fP ]
+[    \fB\-\-ignoreunsupported\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelocal\fP ]
+[    \fB\-\-ignorelocal\fP ]
 .ad b
 .br
 .ad l
-[    \fB--mergedconfig\fP ]
+[    \fB\-\-mergedconfig\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--sinceversion\fP \fIString\fP ]
+[    \fB\-\-sinceversion\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--showdeprecated\fP ]
+[    \fB\-\-showdeprecated\fP ]
 .ad b
 .br
 .ad l
-[    \fB--showunsupported\fP ]
+[    \fB\-\-showunsupported\fP ]
 .ad b
 .br
 .ad l
-[    \fB--validate\fP ]
+[    \fB\-\-validate\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withsummary\fP ]
+[    \fB\-\-withsummary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withcomments\fP ]
+[    \fB\-\-withcomments\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withspaces\fP ]
+[    \fB\-\-withspaces\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unconfigured\fP ]
+[    \fB\-\-unconfigured\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withversions\fP ]
+[    \fB\-\-withversions\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -102,57 +102,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--atversion\fP \fIString\fP
+\fB\-\-atversion\fP \fIString\fP
 .br
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
@@ -164,14 +164,14 @@ issue a warning message when checking the configuration.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -180,45 +180,45 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--file\fP \fIString\fP
+\fB-f\fP|\fB\-\-file\fP \fIString\fP
 .br
 Write output to the named file.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignoreadvanced\fP
+\fB\-\-ignoreadvanced\fP
 .br
 Exclude advanced configuration settings from the output.
 .ad b
 .HP
 .ad l
-\fB--ignorelocal\fP
+\fB\-\-ignorelocal\fP
 .br
 Ignore local section.
 .ad b
 .HP
 .ad l
-\fB--ignoreunsupported\fP
+\fB\-\-ignoreunsupported\fP
 .br
 Exclude unsupported configuration settings from the output. These settings are
 either used for debugging and development purposes only or their support is not
@@ -228,24 +228,24 @@ all the other types ignore unsupported settings.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--list\fP
+\fB-l\fP|\fB\-\-list\fP
 .br
 List config settings with summarizing comment. This is the same as using
-options --typeconfig list --withsummary.
+options \-\-typeconfig list \-\-withsummary.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--mergedconfig\fP
+\fB\-\-mergedconfig\fP
 .br
-When the command is run with --config
-and/or --commandprofile (or using LVM_COMMAND_PROFILE
-environment variable), --profile, or --metadataprofile,
+When the command is run with \-\-config
+and/or \-\-commandprofile (or using LVM_COMMAND_PROFILE
+environment variable), \-\-profile, or \-\-metadataprofile,
 merge all the contents of the "config cascade" before displaying it.
 Without merging, only the configuration at the front of the
 cascade is displayed.
@@ -253,39 +253,39 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--metadataprofile\fP \fIString\fP
+\fB\-\-metadataprofile\fP \fIString\fP
 .br
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--showdeprecated\fP
+\fB\-\-showdeprecated\fP
 .br
 Include deprecated configuration settings in the output. These settings
 are deprecated after a certain version. If a concrete version is specified
-with --atversion, deprecated settings are automatically included
+with \-\-atversion, deprecated settings are automatically included
 if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
 .ad b
 .HP
 .ad l
-\fB--showunsupported\fP
+\fB\-\-showunsupported\fP
 .br
 Include unsupported configuration settings in the output. These settings
 are either used for debugging or development purposes only, or their support
@@ -295,16 +295,16 @@ output by default, all the other types ignore unsupported settings.
 .ad b
 .HP
 .ad l
-\fB--sinceversion\fP \fIString\fP
+\fB\-\-sinceversion\fP \fIString\fP
 .br
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-This option is currently applicable only with --typeconfig new
+This option is currently applicable only with \-\-typeconfig new
 to display all configuration settings introduced since given version.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -314,61 +314,61 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
+\fB\-\-typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB--unconfigured\fP
+\fB\-\-unconfigured\fP
 .br
 Internal option used for generating config file during build.
 .ad b
 .HP
 .ad l
-\fB--validate\fP
+\fB\-\-validate\fP
 .br
 Validate current configuration used and exit with appropriate
 return code. The validation is done only for the configuration
 at the front of the "config cascade". To validate the whole
-merged configuration tree, also use --mergedconfig.
+merged configuration tree, also use \-\-mergedconfig.
 The validation is done even if lvm.conf config/checks is disabled.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB--withcomments\fP
+\fB\-\-withcomments\fP
 .br
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
 .ad b
 .HP
 .ad l
-\fB--withspaces\fP
+\fB\-\-withspaces\fP
 .br
 Where appropriate, add more spaces in output for better readability.
 .ad b
 .HP
 .ad l
-\fB--withsummary\fP
+\fB\-\-withsummary\fP
 .br
 Display a one line comment for each configuration node.
 .ad b
 .HP
 .ad l
-\fB--withversions\fP
+\fB\-\-withversions\fP
 .br
 Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
@@ -376,7 +376,7 @@ the version since which it is deprecated.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -398,7 +398,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvm-dumpconfig.8_pregen b/man/lvm-dumpconfig.8_pregen
index 34c329c..28816ad 100644
--- a/man/lvm-dumpconfig.8_pregen
+++ b/man/lvm-dumpconfig.8_pregen
@@ -20,75 +20,75 @@ line settings from \-\-config.
 .br
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--file\fP \fIString\fP ]
+[ \fB-f\fP|\fB\-\-file\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-l\fP|\fB--list\fP ]
+[ \fB-l\fP|\fB\-\-list\fP ]
 .ad b
 .br
 .ad l
-[    \fB--atversion\fP \fIString\fP ]
+[    \fB\-\-atversion\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
+[    \fB\-\-typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreadvanced\fP ]
+[    \fB\-\-ignoreadvanced\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreunsupported\fP ]
+[    \fB\-\-ignoreunsupported\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelocal\fP ]
+[    \fB\-\-ignorelocal\fP ]
 .ad b
 .br
 .ad l
-[    \fB--mergedconfig\fP ]
+[    \fB\-\-mergedconfig\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--sinceversion\fP \fIString\fP ]
+[    \fB\-\-sinceversion\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--showdeprecated\fP ]
+[    \fB\-\-showdeprecated\fP ]
 .ad b
 .br
 .ad l
-[    \fB--showunsupported\fP ]
+[    \fB\-\-showunsupported\fP ]
 .ad b
 .br
 .ad l
-[    \fB--validate\fP ]
+[    \fB\-\-validate\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withsummary\fP ]
+[    \fB\-\-withsummary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withcomments\fP ]
+[    \fB\-\-withcomments\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withspaces\fP ]
+[    \fB\-\-withspaces\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unconfigured\fP ]
+[    \fB\-\-unconfigured\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withversions\fP ]
+[    \fB\-\-withversions\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -102,57 +102,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--atversion\fP \fIString\fP
+\fB\-\-atversion\fP \fIString\fP
 .br
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
@@ -164,14 +164,14 @@ issue a warning message when checking the configuration.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -180,45 +180,45 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--file\fP \fIString\fP
+\fB-f\fP|\fB\-\-file\fP \fIString\fP
 .br
 Write output to the named file.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignoreadvanced\fP
+\fB\-\-ignoreadvanced\fP
 .br
 Exclude advanced configuration settings from the output.
 .ad b
 .HP
 .ad l
-\fB--ignorelocal\fP
+\fB\-\-ignorelocal\fP
 .br
 Ignore local section.
 .ad b
 .HP
 .ad l
-\fB--ignoreunsupported\fP
+\fB\-\-ignoreunsupported\fP
 .br
 Exclude unsupported configuration settings from the output. These settings are
 either used for debugging and development purposes only or their support is not
@@ -228,24 +228,24 @@ all the other types ignore unsupported settings.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--list\fP
+\fB-l\fP|\fB\-\-list\fP
 .br
 List config settings with summarizing comment. This is the same as using
-options --typeconfig list --withsummary.
+options \-\-typeconfig list \-\-withsummary.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--mergedconfig\fP
+\fB\-\-mergedconfig\fP
 .br
-When the command is run with --config
-and/or --commandprofile (or using LVM_COMMAND_PROFILE
-environment variable), --profile, or --metadataprofile,
+When the command is run with \-\-config
+and/or \-\-commandprofile (or using LVM_COMMAND_PROFILE
+environment variable), \-\-profile, or \-\-metadataprofile,
 merge all the contents of the "config cascade" before displaying it.
 Without merging, only the configuration at the front of the
 cascade is displayed.
@@ -253,39 +253,39 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--metadataprofile\fP \fIString\fP
+\fB\-\-metadataprofile\fP \fIString\fP
 .br
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--showdeprecated\fP
+\fB\-\-showdeprecated\fP
 .br
 Include deprecated configuration settings in the output. These settings
 are deprecated after a certain version. If a concrete version is specified
-with --atversion, deprecated settings are automatically included
+with \-\-atversion, deprecated settings are automatically included
 if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
 .ad b
 .HP
 .ad l
-\fB--showunsupported\fP
+\fB\-\-showunsupported\fP
 .br
 Include unsupported configuration settings in the output. These settings
 are either used for debugging or development purposes only, or their support
@@ -295,16 +295,16 @@ output by default, all the other types ignore unsupported settings.
 .ad b
 .HP
 .ad l
-\fB--sinceversion\fP \fIString\fP
+\fB\-\-sinceversion\fP \fIString\fP
 .br
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-This option is currently applicable only with --typeconfig new
+This option is currently applicable only with \-\-typeconfig new
 to display all configuration settings introduced since given version.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -314,61 +314,61 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
+\fB\-\-typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB--unconfigured\fP
+\fB\-\-unconfigured\fP
 .br
 Internal option used for generating config file during build.
 .ad b
 .HP
 .ad l
-\fB--validate\fP
+\fB\-\-validate\fP
 .br
 Validate current configuration used and exit with appropriate
 return code. The validation is done only for the configuration
 at the front of the "config cascade". To validate the whole
-merged configuration tree, also use --mergedconfig.
+merged configuration tree, also use \-\-mergedconfig.
 The validation is done even if lvm.conf config/checks is disabled.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB--withcomments\fP
+\fB\-\-withcomments\fP
 .br
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
 .ad b
 .HP
 .ad l
-\fB--withspaces\fP
+\fB\-\-withspaces\fP
 .br
 Where appropriate, add more spaces in output for better readability.
 .ad b
 .HP
 .ad l
-\fB--withsummary\fP
+\fB\-\-withsummary\fP
 .br
 Display a one line comment for each configuration node.
 .ad b
 .HP
 .ad l
-\fB--withversions\fP
+\fB\-\-withversions\fP
 .br
 Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
@@ -376,7 +376,7 @@ the version since which it is deprecated.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -398,7 +398,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 25d780e..feb7f8d 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -21,103 +21,103 @@ if information changes between commands.
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--all\fP ]
+[ \fB-a\fP|\fB\-\-all\fP ]
 .ad b
 .br
 .ad l
-[ \fB-o\fP|\fB--options\fP \fIString\fP ]
+[ \fB-o\fP|\fB\-\-options\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-O\fP|\fB--sort\fP \fIString\fP ]
+[ \fB-O\fP|\fB\-\-sort\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--aligned\fP ]
+[    \fB\-\-aligned\fP ]
 .ad b
 .br
 .ad l
-[    \fB--binary\fP ]
+[    \fB\-\-binary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
+[    \fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
 .ad b
 .br
 .ad l
-[    \fB--foreign\fP ]
+[    \fB\-\-foreign\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--logonly\fP ]
+[    \fB\-\-logonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nameprefixes\fP ]
+[    \fB\-\-nameprefixes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noheadings\fP ]
+[    \fB\-\-noheadings\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nolocking\fP ]
+[    \fB\-\-nolocking\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosuffix\fP ]
+[    \fB\-\-nosuffix\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--rows\fP ]
+[    \fB\-\-rows\fP ]
 .ad b
 .br
 .ad l
-[    \fB--separator\fP \fIString\fP ]
+[    \fB\-\-separator\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--shared\fP ]
+[    \fB\-\-shared\fP ]
 .ad b
 .br
 .ad l
-[    \fB--trustcache\fP ]
+[    \fB\-\-trustcache\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unbuffered\fP ]
+[    \fB\-\-unbuffered\fP ]
 .ad b
 .br
 .ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
+[    \fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unquoted\fP ]
+[    \fB\-\-unquoted\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -131,68 +131,68 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--aligned\fP
+\fB\-\-aligned\fP
 .br
-Use with --separator to align the output columns
+Use with \-\-separator to align the output columns
 .ad b
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 .ad b
 .HP
 .ad l
-\fB--binary\fP
+\fB\-\-binary\fP
 .br
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
@@ -200,14 +200,14 @@ the "unknown" value which denotes that the value could not be determined).
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -216,94 +216,94 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
+\fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--foreign\fP
+\fB\-\-foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--logonly\fP
+\fB\-\-logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--nameprefixes\fP
+\fB\-\-nameprefixes\fP
 .br
 Add an "LVM2_" prefix plus the field name to the output. Useful
-with --noheadings to produce a list of field=value pairs that can
+with \-\-noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
 .ad b
 .HP
 .ad l
-\fB--noheadings\fP
+\fB\-\-noheadings\fP
 .br
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--nolocking\fP
+\fB\-\-nolocking\fP
 .br
 Disable locking.
 .ad b
 .HP
 .ad l
-\fB--nosuffix\fP
+\fB\-\-nosuffix\fP
 .br
-Suppress the suffix on output sizes. Use with --units
+Suppress the suffix on output sizes. Use with \-\-units
 (except h and H) if processing the output.
 .ad b
 .HP
 .ad l
-\fB-o\fP|\fB--options\fP \fIString\fP
+\fB-o\fP|\fB\-\-options\fP \fIString\fP
 .br
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
@@ -325,7 +325,7 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -334,21 +334,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -362,7 +362,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -373,18 +373,18 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--rows\fP
+\fB\-\-rows\fP
 .br
 Output columns as rows.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -392,13 +392,13 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB--separator\fP \fIString\fP
+\fB\-\-separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--shared\fP
+\fB\-\-shared\fP
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
@@ -406,14 +406,14 @@ See lvmlockd(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
-\fB-O\fP|\fB--sort\fP \fIString\fP
+\fB-O\fP|\fB\-\-sort\fP \fIString\fP
 .br
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -423,50 +423,50 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--trustcache\fP
+\fB\-\-trustcache\fP
 .br
 Avoids certain device scanning during command processing. Do not use.
 .ad b
 .HP
 .ad l
-\fB--unbuffered\fP
+\fB\-\-unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
+\fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
-Custom units can be specified, e.g. --units 3M.
+Custom units can be specified, e.g. \-\-units 3M.
 .ad b
 .HP
 .ad l
-\fB--unquoted\fP
+\fB\-\-unquoted\fP
 .br
-When used with --nameprefixes, output values in the field=value
+When used with \-\-nameprefixes, output values in the field=value
 pairs are not quoted.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -492,7 +492,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvm-lvpoll.8_end b/man/lvm-lvpoll.8_end
index d38dfd0..efd0f18 100644
--- a/man/lvm-lvpoll.8_end
+++ b/man/lvm-lvpoll.8_end
@@ -8,24 +8,24 @@ To find the name of the pvmove LV that was created by an original
 
 Continue polling a pvmove operation.
 .br
-.B lvm lvpoll --polloperation pvmove vg00/pvmove0
+.B lvm lvpoll \-\-polloperation pvmove vg00/pvmove0
 
 Abort a pvmove operation.
 .br
-.B lvm lvpoll --polloperation pvmove --abort vg00/pvmove0
+.B lvm lvpoll \-\-polloperation pvmove \-\-abort vg00/pvmove0
 
 Continue polling a mirror conversion.
 .br
-.B lvm lvpoll --polloperation convert vg00/lvmirror
+.B lvm lvpoll \-\-polloperation convert vg00/lvmirror
 
 Continue mirror repair.
 .br
-.B lvm lvpoll --polloperation convert vg/damaged_mirror --handlemissingpvs
+.B lvm lvpoll \-\-polloperation convert vg/damaged_mirror \-\-handlemissingpvs
 
 Continue snapshot merge.
 .br
-.B lvm lvpoll --polloperation merge vg/snapshot_old
+.B lvm lvpoll \-\-polloperation merge vg/snapshot_old
 
 Continue thin snapshot merge.
 .br
-.B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
+.B lvm lvpoll \-\-polloperation merge_thin vg/thin_snapshot
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index fde6d93..20af1be 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -13,23 +13,23 @@ complete \fBlvconvert\fP(8) and \fBpvmove\fP(8) operations. lvpoll itself
 does not initiate these operations and should not normally need to be run
 directly.
 .SH USAGE
-\fBlvm lvpoll\fP \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP \fILV\fP ...
+\fBlvm lvpoll\fP \fB\-\-polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP \fILV\fP ...
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--abort\fP ]
+[    \fB\-\-abort\fP ]
 .ad b
 .br
 .ad l
-[    \fB--handlemissingpvs\fP ]
+[    \fB\-\-handlemissingpvs\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -40,77 +40,77 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--abort\fP
+\fB\-\-abort\fP
 .br
 Stop processing a poll operation in lvmpolld.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -119,66 +119,66 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--handlemissingpvs\fP
+\fB\-\-handlemissingpvs\fP
 .br
 Allows a polling operation to continue when PVs are missing,
 e.g. for repairs due to faulty devices.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-i\fP|\fB--interval\fP \fINumber\fP
+\fB-i\fP|\fB\-\-interval\fP \fINumber\fP
 .br
 Report progress@regular intervals.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP
+\fB\-\-polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP
 .br
 The command to perform from lvmpolld.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -188,20 +188,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -228,7 +228,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
@@ -243,27 +243,27 @@ To find the name of the pvmove LV that was created by an original
 
 Continue polling a pvmove operation.
 .br
-.B lvm lvpoll --polloperation pvmove vg00/pvmove0
+.B lvm lvpoll \-\-polloperation pvmove vg00/pvmove0
 
 Abort a pvmove operation.
 .br
-.B lvm lvpoll --polloperation pvmove --abort vg00/pvmove0
+.B lvm lvpoll \-\-polloperation pvmove \-\-abort vg00/pvmove0
 
 Continue polling a mirror conversion.
 .br
-.B lvm lvpoll --polloperation convert vg00/lvmirror
+.B lvm lvpoll \-\-polloperation convert vg00/lvmirror
 
 Continue mirror repair.
 .br
-.B lvm lvpoll --polloperation convert vg/damaged_mirror --handlemissingpvs
+.B lvm lvpoll \-\-polloperation convert vg/damaged_mirror \-\-handlemissingpvs
 
 Continue snapshot merge.
 .br
-.B lvm lvpoll --polloperation merge vg/snapshot_old
+.B lvm lvpoll \-\-polloperation merge vg/snapshot_old
 
 Continue thin snapshot merge.
 .br
-.B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
+.B lvm lvpoll \-\-polloperation merge_thin vg/thin_snapshot
 .SH SEE ALSO
 
 .BR lvm (8)
diff --git a/man/lvm.8_main b/man/lvm.8_main
index dd60da0..aa80d05 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -253,7 +253,7 @@ least one LV that is still present.  This helps to record the ancestry of
 thin snapshots even after some links in the chain have been removed.
 A reference to the historical LV 'lvol1' in VG 'vg00' would be 'vg00/-lvol1'
 or just '-lvol1' if the VG is already set.  (The latter form must be preceded
-by '--' to terminate command line option processing before reaching this
+by '\-\-' to terminate command line option processing before reaching this
 argument.)
 .P
 There are also various reserved names that are used internally by lvm that can
@@ -288,8 +288,8 @@ When VGs with the same name exist, commands operating on all VGs will
 include all of the VGs with the same name.  If the ambiguous VG name is
 specified on the command line, the command will produce an error.  The
 error states that multiple VGs exist with the specified name.  To process
-one of the VGs specifically, the --select option should be used with the
-UUID of the intended VG: '--select vg_uuid=<uuid>'.
+one of the VGs specifically, the \-\-select option should be used with the
+UUID of the intended VG: '\-\-select vg_uuid=<uuid>'.
 
 An exception is if all but one of the VGs with the shared name is foreign
 (see
diff --git a/man/lvm.conf.5_main b/man/lvm.conf.5_main
index ae884be..d21cf71 100644
--- a/man/lvm.conf.5_main
+++ b/man/lvm.conf.5_main
@@ -171,7 +171,7 @@ default values:
 Command to print a list of all possible config settings, with their
 default values, and a full description of each as a comment:
 .br
-.B lvmconfig \-\-type default --withcomments
+.B lvmconfig \-\-type default \-\-withcomments
 
 Command to print a list of all possible config settings, with their
 current values (configured, non-default values are shown):
@@ -189,7 +189,7 @@ and a full description, where "Section" refers to the config section,
 e.g. global, and "Setting" refers to the name of the specific setting,
 e.g. umask:
 .br
-.B lvmconfig \-\-type default --withcomments Section/Setting
+.B lvmconfig \-\-type default \-\-withcomments Section/Setting
 
 
 .SH FILES
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 45bb5b1..4ba9449 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -71,9 +71,9 @@ a minimum size of 8MiB.
 .nf
 # lvs -a vg
   LV         VG   Attr       LSize   Pool Origin
-  cache0     vg   -wi-a-----  10.00g                                                    
-  cache0meta vg   -wi-a-----  12.00m                                                    
-  lvol0      vg   -wi-a----- 100.00g
+  cache0     vg   -wi-a\-\-\-\--  10.00g                                                    
+  cache0meta vg   -wi-a\-\-\-\--  12.00m                                                    
+  lvol0      vg   -wi-a\-\-\-\-- 100.00g
 .fi
 
 
@@ -100,10 +100,10 @@ CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 .nf
 # lvs -a vg
   LV              VG   Attr       LSize   Pool Origin
-  cache0          vg   Cwi---C---  10.00g
-  [cache0_cdata]  vg   Cwi-------  10.00g
-  [cache0_cmeta]  vg   ewi-------  12.00m
-  lvol0           vg   -wi-a----- 100.00g
+  cache0          vg   Cwi\-\--C\-\--  10.00g
+  [cache0_cdata]  vg   Cwi\-\-\-\-\-\--  10.00g
+  [cache0_cmeta]  vg   ewi\-\-\-\-\-\--  12.00m
+  lvol0           vg   -wi-a\-\-\-\-- 100.00g
 .fi
 
 
@@ -127,11 +127,11 @@ OriginLV is renamed OriginLV_corig and becomes hidden.
 .nf
 # lvs -a vg
   LV              VG   Attr       LSize   Pool   Origin
-  cache0          vg   Cwi---C---  10.00g                                                             
-  [cache0_cdata]  vg   Cwi-ao----  10.00g                                                             
-  [cache0_cmeta]  vg   ewi-ao----  12.00m                                                             
-  lvol0           vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]                                        
-  [lvol0_corig]   vg   -wi-ao---- 100.00g                                                             
+  cache0          vg   Cwi\-\--C\-\--  10.00g                                                             
+  [cache0_cdata]  vg   Cwi-ao\-\-\-\-  10.00g                                                             
+  [cache0_cmeta]  vg   ewi-ao\-\-\-\-  12.00m                                                             
+  lvol0           vg   Cwi-a-C\-\-- 100.00g cache0 [lvol0_corig]                                        
+  [lvol0_corig]   vg   -wi-ao\-\-\-\- 100.00g                                                             
 .fi
 
 
@@ -145,7 +145,7 @@ A cache pool LV can be disconnected from a cache LV, leaving an
 unused cache pool LV, and an uncached origin LV.  This command
 writes back data from the cache pool to the origin LV when necessary.
 
-.B lvconvert --splitcache VG/CacheLV
+.B lvconvert \-\-splitcache VG/CacheLV
 
 .SS Removing a cache pool LV without removing its linked origin LV
 
@@ -159,20 +159,20 @@ then removes the cache pool LV, leaving the uncached origin LV.
 An alternative command that also disconnects the cache pool from the cache
 LV, and deletes the cache pool:
 
-.B lvconvert --uncache VG/CacheLV
+.B lvconvert \-\-uncache VG/CacheLV
 
 .I Example
 .nf
 # lvs vg
   LV     VG   Attr       LSize   Pool   Origin
-  cache0 vg   Cwi---C---  10.00g
-  lvol0  vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]
+  cache0 vg   Cwi\-\--C\-\--  10.00g
+  lvol0  vg   Cwi-a-C\-\-- 100.00g cache0 [lvol0_corig]
 
 # lvremove vg/cache0
 
 # lvs vg
   LV    VG   Attr       LSize   Pool Origin
-  lvol0 vg   -wi-a----- 100.00g
+  lvol0 vg   -wi-a\-\-\-\-- 100.00g
 .fi
 
 .SS Removing a cache LV: both origin LV and the cache pool LV
@@ -349,7 +349,7 @@ the same VG.
 
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert --type cache\-pool VG/CacheDataLV
+.B lvconvert \-\-type cache\-pool VG/CacheDataLV
 
 
 .SS Create a new cache LV without an existing origin LV
@@ -390,7 +390,7 @@ may optionally be specified.
 .br
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert --type cache --cachepool VG/CataDataLV VG/OriginLV
+.B lvconvert \-\-type cache \-\-cachepool VG/CataDataLV VG/OriginLV
 
 This is equivalent to:
 
@@ -398,9 +398,9 @@ This is equivalent to:
 .br
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert --type cache-pool VG/CacheDataLV
+.B lvconvert \-\-type cache-pool VG/CacheDataLV
 .br
-.B lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
+.B lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
 
 
 .SH SEE ALSO
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 3ed8137..dc9ff65 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -18,75 +18,75 @@ line settings from \-\-config.
 .br
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--file\fP \fIString\fP ]
+[ \fB-f\fP|\fB\-\-file\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-l\fP|\fB--list\fP ]
+[ \fB-l\fP|\fB\-\-list\fP ]
 .ad b
 .br
 .ad l
-[    \fB--atversion\fP \fIString\fP ]
+[    \fB\-\-atversion\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
+[    \fB\-\-typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreadvanced\fP ]
+[    \fB\-\-ignoreadvanced\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreunsupported\fP ]
+[    \fB\-\-ignoreunsupported\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelocal\fP ]
+[    \fB\-\-ignorelocal\fP ]
 .ad b
 .br
 .ad l
-[    \fB--mergedconfig\fP ]
+[    \fB\-\-mergedconfig\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--sinceversion\fP \fIString\fP ]
+[    \fB\-\-sinceversion\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--showdeprecated\fP ]
+[    \fB\-\-showdeprecated\fP ]
 .ad b
 .br
 .ad l
-[    \fB--showunsupported\fP ]
+[    \fB\-\-showunsupported\fP ]
 .ad b
 .br
 .ad l
-[    \fB--validate\fP ]
+[    \fB\-\-validate\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withsummary\fP ]
+[    \fB\-\-withsummary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withcomments\fP ]
+[    \fB\-\-withcomments\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withspaces\fP ]
+[    \fB\-\-withspaces\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unconfigured\fP ]
+[    \fB\-\-unconfigured\fP ]
 .ad b
 .br
 .ad l
-[    \fB--withversions\fP ]
+[    \fB\-\-withversions\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -100,57 +100,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--atversion\fP \fIString\fP
+\fB\-\-atversion\fP \fIString\fP
 .br
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
@@ -162,14 +162,14 @@ issue a warning message when checking the configuration.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -178,45 +178,45 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--file\fP \fIString\fP
+\fB-f\fP|\fB\-\-file\fP \fIString\fP
 .br
 Write output to the named file.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignoreadvanced\fP
+\fB\-\-ignoreadvanced\fP
 .br
 Exclude advanced configuration settings from the output.
 .ad b
 .HP
 .ad l
-\fB--ignorelocal\fP
+\fB\-\-ignorelocal\fP
 .br
 Ignore local section.
 .ad b
 .HP
 .ad l
-\fB--ignoreunsupported\fP
+\fB\-\-ignoreunsupported\fP
 .br
 Exclude unsupported configuration settings from the output. These settings are
 either used for debugging and development purposes only or their support is not
@@ -226,24 +226,24 @@ all the other types ignore unsupported settings.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--list\fP
+\fB-l\fP|\fB\-\-list\fP
 .br
 List config settings with summarizing comment. This is the same as using
-options --typeconfig list --withsummary.
+options \-\-typeconfig list \-\-withsummary.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--mergedconfig\fP
+\fB\-\-mergedconfig\fP
 .br
-When the command is run with --config
-and/or --commandprofile (or using LVM_COMMAND_PROFILE
-environment variable), --profile, or --metadataprofile,
+When the command is run with \-\-config
+and/or \-\-commandprofile (or using LVM_COMMAND_PROFILE
+environment variable), \-\-profile, or \-\-metadataprofile,
 merge all the contents of the "config cascade" before displaying it.
 Without merging, only the configuration at the front of the
 cascade is displayed.
@@ -251,39 +251,39 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--metadataprofile\fP \fIString\fP
+\fB\-\-metadataprofile\fP \fIString\fP
 .br
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--showdeprecated\fP
+\fB\-\-showdeprecated\fP
 .br
 Include deprecated configuration settings in the output. These settings
 are deprecated after a certain version. If a concrete version is specified
-with --atversion, deprecated settings are automatically included
+with \-\-atversion, deprecated settings are automatically included
 if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
 .ad b
 .HP
 .ad l
-\fB--showunsupported\fP
+\fB\-\-showunsupported\fP
 .br
 Include unsupported configuration settings in the output. These settings
 are either used for debugging or development purposes only, or their support
@@ -293,16 +293,16 @@ output by default, all the other types ignore unsupported settings.
 .ad b
 .HP
 .ad l
-\fB--sinceversion\fP \fIString\fP
+\fB\-\-sinceversion\fP \fIString\fP
 .br
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-This option is currently applicable only with --typeconfig new
+This option is currently applicable only with \-\-typeconfig new
 to display all configuration settings introduced since given version.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -312,61 +312,61 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
+\fB\-\-typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB--unconfigured\fP
+\fB\-\-unconfigured\fP
 .br
 Internal option used for generating config file during build.
 .ad b
 .HP
 .ad l
-\fB--validate\fP
+\fB\-\-validate\fP
 .br
 Validate current configuration used and exit with appropriate
 return code. The validation is done only for the configuration
 at the front of the "config cascade". To validate the whole
-merged configuration tree, also use --mergedconfig.
+merged configuration tree, also use \-\-mergedconfig.
 The validation is done even if lvm.conf config/checks is disabled.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB--withcomments\fP
+\fB\-\-withcomments\fP
 .br
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
 .ad b
 .HP
 .ad l
-\fB--withspaces\fP
+\fB\-\-withspaces\fP
 .br
 Where appropriate, add more spaces in output for better readability.
 .ad b
 .HP
 .ad l
-\fB--withsummary\fP
+\fB\-\-withsummary\fP
 .br
 Display a one line comment for each configuration node.
 .ad b
 .HP
 .ad l
-\fB--withversions\fP
+\fB\-\-withversions\fP
 .br
 Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
@@ -374,7 +374,7 @@ the version since which it is deprecated.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -396,7 +396,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index b8c5025..f6b3c53 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -20,11 +20,11 @@ This command is deprecated, use \fBpvs\fP instead.
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--lvmpartition\fP ]
+[ \fB-l\fP|\fB\-\-lvmpartition\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -35,64 +35,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -101,53 +101,53 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--lvmpartition\fP
+\fB-l\fP|\fB\-\-lvmpartition\fP
 .br
 Only report PVs.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -161,7 +161,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -171,20 +171,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -206,7 +206,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvmlockctl.8_main b/man/lvmlockctl.8_main
index 5465642..fc18fcb 100644
--- a/man/lvmlockctl.8_main
+++ b/man/lvmlockctl.8_main
@@ -55,7 +55,7 @@ lvmlockctl [options]
 
 This collects and displays lock state from lvmlockd.  The display is
 primitive, incomplete and will change in future version.  To print the raw
-lock state from lvmlockd, combine this option with --dump|-d.
+lock state from lvmlockd, combine this option with \-\-dump|-d.
 
 .SS dump
 
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 6e9b703..bca8ecd 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -687,7 +687,7 @@ original cluster:
 .IP \[bu] 2
 Stop the VG on all hosts:
 .br
-vgchange --lock-stop <vgname>
+vgchange \-\-lock-stop <vgname>
 
 .IP \[bu] 2
 Change the VG lock type to none:
@@ -709,7 +709,7 @@ vgchange \-\-lock\-type dlm <vgname>
 .IP \[bu] 2
 Start the VG on hosts to use it:
 .br
-vgchange --lock-start <vgname>
+vgchange \-\-lock-start <vgname>
 
 .P
 
@@ -738,7 +738,7 @@ vgchange \-\-lock\-type dlm <vgname>
 .IP \[bu] 2
 Start the VG on hosts to use it:
 .br
-vgchange --lock-start <vgname>
+vgchange \-\-lock-start <vgname>
 
 
 .SS changing a local VG to a lockd VG
diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 8ac59c6..3d75e79 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -423,7 +423,7 @@ Each rimage SubLV holds a portion of LV data.  No parity is used.
 No RAID metadata is used.
 
 .nf
-lvcreate --type raid0 --stripes 2 --name lvr0 ...
+lvcreate \-\-type raid0 \-\-stripes 2 \-\-name lvr0 ...
 
 lvs -a -o name,segtype,devices
   lvr0            raid0  lvr0_rimage_0(0),lvr0_rimage_1(0)
@@ -437,7 +437,7 @@ Each rimage SubLV holds a complete copy of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid1 --mirrors 1 --name lvr1 ...
+lvcreate \-\-type raid1 \-\-mirrors 1 \-\-name lvr1 ...
 
 lvs -a -o name,segtype,devices
   lvr1            raid1  lvr1_rimage_0(0),lvr1_rimage_1(0)
@@ -453,7 +453,7 @@ Two rimage SubLVs each hold a portion of LV data and one rimage SubLV
 holds parity.  Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid4 --stripes 2 --name lvr4 ...
+lvcreate \-\-type raid4 \-\-stripes 2 \-\-name lvr4 ...
 
 lvs -a -o name,segtype,devices
   lvr4            raid4  lvr4_rimage_0(0),\\
@@ -473,7 +473,7 @@ Three rimage SubLVs each hold a portion of LV data and parity.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid5 --stripes 2 --name lvr5 ...
+lvcreate \-\-type raid5 \-\-stripes 2 \-\-name lvr5 ...
 
 lvs -a -o name,segtype,devices
   lvr5            raid5  lvr5_rimage_0(0),\\
@@ -493,7 +493,7 @@ Six rimage SubLVs each hold a portion of LV data and parity.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid6 --stripes 3 --name lvr6
+lvcreate \-\-type raid6 \-\-stripes 3 \-\-name lvr6
 
 lvs -a -o name,segtype,devices
   lvr6            raid6  lvr6_rimage_0(0),\\
@@ -521,7 +521,7 @@ Four rimage SubLVs each hold a portion of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate --type raid10 --stripes 2 --mirrors 1 --name lvr10
+lvcreate \-\-type raid10 \-\-stripes 2 \-\-mirrors 1 \-\-name lvr10
 
 lvs -a -o name,segtype,devices
   lvr10            raid10 lvr10_rimage_0(0),\\
@@ -634,7 +634,7 @@ controls the activation mode when not specified by the command.
 
 The default value is printed by:
 .nf
-lvmconfig --type default activation/activation_mode
+lvmconfig \-\-type default activation/activation_mode
 .fi
 
 .SS Replacing Devices
@@ -685,11 +685,11 @@ the lvchange command to refresh an LV:
   LV    VG   Type  Attr       LSize
   raid1 vg   raid1 Rwi-a-r-r- 100.00g
 
-# lvchange --refresh vg/raid1
+# lvchange \-\-refresh vg/raid1
 
 # lvs -o name,vgname,segtype,attr,size vg
   LV    VG   Type  Attr       LSize
-  raid1 vg   raid1 Rwi-a-r--- 100.00g
+  raid1 vg   raid1 Rwi-a-r\-\-- 100.00g
 .fi
 
 .SS Automatic repair
@@ -827,7 +827,7 @@ raid5 to raid6.  Changing the RAID level is usually done to increase or
 decrease resilience to device failures or to restripe LVs.  This is done
 using lvconvert and specifying the new RAID level as the LV type:
 
-.B lvconvert --type
+.B lvconvert \-\-type
 .I RaidLevel
 \fIVG\fP/\fILV\fP
 [\fIPVs\fP]
@@ -906,7 +906,7 @@ between striped/raid0 and raid10.
   LV   Type   LSize
   lv   linear 300.00g
 
-# lvconvert --type raid1 --mirrors 1 vg/lv
+# lvconvert \-\-type raid1 \-\-mirrors 1 vg/lv
 
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
@@ -938,7 +938,7 @@ between striped and raid4.
   LV   Type   LSize
   lv   linear 300.00g
 
-# lvconvert --type raid1 --mirrors 1 vg/lv
+# lvconvert \-\-type raid1 \-\-mirrors 1 vg/lv
 
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
@@ -959,7 +959,7 @@ between striped and raid4.
   [lv_mimage_1] linear 100.00g
   [lv_mlog]     linear   3.00m
 
-# lvconvert --type raid1 vg/lv
+# lvconvert \-\-type raid1 vg/lv
 
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
@@ -980,7 +980,7 @@ Start with a linear LV:
 Convert the linear LV to raid1 with three images
 (original linear image plus 2 mirror images):
 
-# lvconvert --type raid1 --mirrors 2 vg/lv
+# lvconvert \-\-type raid1 \-\-mirrors 2 vg/lv
 .fi
 
 4. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_nc\fP.
@@ -988,11 +988,11 @@ Convert the linear LV to raid1 with three images
 .nf
 Start with a striped LV:
 
-# lvcreate --stripes 4 -L64M -n lv vg
+# lvcreate \-\-stripes 4 -L64M -n lv vg
 
 Convert the striped LV to raid6_n_6:
 
-# lvconvert --type raid6 vg/lv
+# lvconvert \-\-type raid6 vg/lv
 
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
   LV            Type      Cpy%Sync #Cpy
@@ -1061,7 +1061,7 @@ traditional RAID6.
   [lv_rmeta_4]  linear
   [lv_rmeta_5]  linear
 
-# lvconvert --type raid6_nr vg/lv
+# lvconvert \-\-type raid6_nr vg/lv
 
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
   LV            Type     Cpy%Sync #Cpy
@@ -1114,7 +1114,7 @@ For performance reasons the raid6_nr RaidLV can be restriped.
 Convert it from 3-way striped to 5-way-striped.
 
 .nf
-# lvconvert --stripes 5 -y tb/lv
+# lvconvert \-\-stripes 5 -y tb/lv
   Using default stripesize 64.00 KiB.
   WARNING: Adding stripes to active logical volume tb/lv will grow it from 99 to 165 extents!
   Run "lvresize -l99 tb/lv" to shrink it or use the additional capacity.
@@ -1122,30 +1122,30 @@ Convert it from 3-way striped to 5-way-striped.
 
 # lvs
   LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
-  root fedora -wi-ao----  15.00g
-  swap fedora -wi-ao----   3.99g
+  root fedora -wi-ao\-\-\-\-  15.00g
+  swap fedora -wi-ao\-\-\-\-   3.99g
   lv   tb     rwi-a-r-s- 652.00m                                    52.94
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                                                   DOff
-  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                               0
-  [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
-  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                                              0
-  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                                              0
-  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                                              0
-  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                                              0
-  [lv_rimage_6] iwi-aor--- linear   /dev/sdaf:1-34                                                                              0
-  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
-  [lv_rmeta_6]  ewi-aor--- linear   /dev/sdaf:0-0
+  lv            rwi-a-r\-\-- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] iwi-aor\-\-- linear   /dev/sda:0-32                                                                               0
+  [lv_rimage_0] iwi-aor\-\-- linear   /dev/sda:34-34
+  [lv_rimage_1] iwi-aor\-\-- linear   /dev/sdaa:0-32                                                                              0
+  [lv_rimage_1] iwi-aor\-\-- linear   /dev/sdaa:34-34
+  [lv_rimage_2] iwi-aor\-\-- linear   /dev/sdab:0-32                                                                              0
+  [lv_rimage_2] iwi-aor\-\-- linear   /dev/sdab:34-34
+  [lv_rimage_3] iwi-aor\-\-- linear   /dev/sdac:1-34                                                                              0
+  [lv_rimage_4] iwi-aor\-\-- linear   /dev/sdad:1-34                                                                              0
+  [lv_rimage_5] iwi-aor\-\-- linear   /dev/sdae:1-34                                                                              0
+  [lv_rimage_6] iwi-aor\-\-- linear   /dev/sdaf:1-34                                                                              0
+  [lv_rmeta_0]  ewi-aor\-\-- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor\-\-- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor\-\-- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor\-\-- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor\-\-- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor\-\-- linear   /dev/sdae:0-0
+  [lv_rmeta_6]  ewi-aor\-\-- linear   /dev/sdaf:0-0
 .fi
 
 Stripes also can be removed from raid5 and 6.
@@ -1154,34 +1154,34 @@ The force option needs to be used, because removing stripes
 (i.e. image SubLVs) from a RaidLV will shrink its size.
 
 .nf
-# lvconvert --stripes 4 --force -y tb/lv
+# lvconvert \-\-stripes 4 \-\-force -y tb/lv
   Using default stripesize 64.00 KiB.
   WARNING: Removing stripes from active logical volume tb/lv will shrink it from 660.00 MiB to 528.00 MiB!
   THIS MAY DESTROY (PARTS OF) YOUR DATA!
   If that leaves the logical volume larger than 206 extents due to stripe rounding,
   you may want to grow the content afterwards (filesystem etc.)
-  WARNING: too remove freed stripes after the conversion has finished, you have to run "lvconvert --stripes 4 tb/lv"
+  WARNING: too remove freed stripes after the conversion has finished, you have to run "lvconvert \-\-stripes 4 tb/lv"
   Logical volume tb/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                                                   DOff
   lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32                                                                               0
-  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
-  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32                                                                              0
-  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34                                                                              0
-  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34                                                                              0
-  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34                                                                              0
+  [lv_rimage_0] Iwi-aor\-\-- linear   /dev/sda:0-32                                                                               0
+  [lv_rimage_0] Iwi-aor\-\-- linear   /dev/sda:34-34
+  [lv_rimage_1] Iwi-aor\-\-- linear   /dev/sdaa:0-32                                                                              0
+  [lv_rimage_1] Iwi-aor\-\-- linear   /dev/sdaa:34-34
+  [lv_rimage_2] Iwi-aor\-\-- linear   /dev/sdab:0-32                                                                              0
+  [lv_rimage_2] Iwi-aor\-\-- linear   /dev/sdab:34-34
+  [lv_rimage_3] Iwi-aor\-\-- linear   /dev/sdac:1-34                                                                              0
+  [lv_rimage_4] Iwi-aor\-\-- linear   /dev/sdad:1-34                                                                              0
+  [lv_rimage_5] Iwi-aor\-\-- linear   /dev/sdae:1-34                                                                              0
   [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34                                                                              0
-  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
+  [lv_rmeta_0]  ewi-aor\-\-- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor\-\-- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor\-\-- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor\-\-- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor\-\-- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor\-\-- linear   /dev/sdae:0-0
   [lv_rmeta_6]  ewi-aor-R- linear   /dev/sdaf:0-0
 .fi
 
@@ -1202,84 +1202,84 @@ Now that the reshape is finished the 'R' atribute on the RaidLV shows images can
   lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ...  lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
 
-This is achieved by repeating the command ("lvconvert --stripes 4 tb/lv" would be sufficient).
+This is achieved by repeating the command ("lvconvert \-\-stripes 4 tb/lv" would be sufficient).
 
 .nf
-# lvconvert --stripes 4 --force -y tb/lv
+# lvconvert \-\-stripes 4 \-\-force -y tb/lv
   Using default stripesize 64.00 KiB.
   Logical volume tb/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                               DOff
-  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
-  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                           8192
-  [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                          8192
-  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                          8192
-  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                          8192
-  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                          8192
-  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                          8192
-  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
+  lv            rwi-a-r\-\-- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
+  [lv_rimage_0] iwi-aor\-\-- linear   /dev/sda:0-32                                                           8192
+  [lv_rimage_0] iwi-aor\-\-- linear   /dev/sda:34-34
+  [lv_rimage_1] iwi-aor\-\-- linear   /dev/sdaa:0-32                                                          8192
+  [lv_rimage_1] iwi-aor\-\-- linear   /dev/sdaa:34-34
+  [lv_rimage_2] iwi-aor\-\-- linear   /dev/sdab:0-32                                                          8192
+  [lv_rimage_2] iwi-aor\-\-- linear   /dev/sdab:34-34
+  [lv_rimage_3] iwi-aor\-\-- linear   /dev/sdac:1-34                                                          8192
+  [lv_rimage_4] iwi-aor\-\-- linear   /dev/sdad:1-34                                                          8192
+  [lv_rimage_5] iwi-aor\-\-- linear   /dev/sdae:1-34                                                          8192
+  [lv_rmeta_0]  ewi-aor\-\-- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor\-\-- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor\-\-- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor\-\-- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor\-\-- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor\-\-- linear   /dev/sdae:0-0
 
 # lvs -a -o lv_name,attr,segtype,reshapelen tb
   LV            Attr       Type     RSize
-  lv            rwi-a-r--- raid6_nr 24.00m
-  [lv_rimage_0] iwi-aor--- linear    4.00m
-  [lv_rimage_0] iwi-aor--- linear
-  [lv_rimage_1] iwi-aor--- linear    4.00m
-  [lv_rimage_1] iwi-aor--- linear
-  [lv_rimage_2] iwi-aor--- linear    4.00m
-  [lv_rimage_2] iwi-aor--- linear
-  [lv_rimage_3] iwi-aor--- linear    4.00m
-  [lv_rimage_4] iwi-aor--- linear    4.00m
-  [lv_rimage_5] iwi-aor--- linear    4.00m
-  [lv_rmeta_0]  ewi-aor--- linear
-  [lv_rmeta_1]  ewi-aor--- linear
-  [lv_rmeta_2]  ewi-aor--- linear
-  [lv_rmeta_3]  ewi-aor--- linear
-  [lv_rmeta_4]  ewi-aor--- linear
-  [lv_rmeta_5]  ewi-aor--- linear
+  lv            rwi-a-r\-\-- raid6_nr 24.00m
+  [lv_rimage_0] iwi-aor\-\-- linear    4.00m
+  [lv_rimage_0] iwi-aor\-\-- linear
+  [lv_rimage_1] iwi-aor\-\-- linear    4.00m
+  [lv_rimage_1] iwi-aor\-\-- linear
+  [lv_rimage_2] iwi-aor\-\-- linear    4.00m
+  [lv_rimage_2] iwi-aor\-\-- linear
+  [lv_rimage_3] iwi-aor\-\-- linear    4.00m
+  [lv_rimage_4] iwi-aor\-\-- linear    4.00m
+  [lv_rimage_5] iwi-aor\-\-- linear    4.00m
+  [lv_rmeta_0]  ewi-aor\-\-- linear
+  [lv_rmeta_1]  ewi-aor\-\-- linear
+  [lv_rmeta_2]  ewi-aor\-\-- linear
+  [lv_rmeta_3]  ewi-aor\-\-- linear
+  [lv_rmeta_4]  ewi-aor\-\-- linear
+  [lv_rmeta_5]  ewi-aor\-\-- linear
 .fi
 
 If the reshape space shall be removed any lvconvert command not changing the layout can be used:
 
 .nf
-# lvconvert --stripes 4 tb/lv
+# lvconvert \-\-stripes 4 tb/lv
   Using default stripesize 64.00 KiB.
   No change in RAID LV tb/lv layout, freeing reshape space.
   Logical volume tb/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,reshapelen tb
   LV            Attr       Type     RSize
-  lv            rwi-a-r--- raid6_nr    0
-  [lv_rimage_0] iwi-aor--- linear      0
-  [lv_rimage_0] iwi-aor--- linear
-  [lv_rimage_1] iwi-aor--- linear      0
-  [lv_rimage_1] iwi-aor--- linear
-  [lv_rimage_2] iwi-aor--- linear      0
-  [lv_rimage_2] iwi-aor--- linear
-  [lv_rimage_3] iwi-aor--- linear      0
-  [lv_rimage_4] iwi-aor--- linear      0
-  [lv_rimage_5] iwi-aor--- linear      0
-  [lv_rmeta_0]  ewi-aor--- linear
-  [lv_rmeta_1]  ewi-aor--- linear
-  [lv_rmeta_2]  ewi-aor--- linear
-  [lv_rmeta_3]  ewi-aor--- linear
-  [lv_rmeta_4]  ewi-aor--- linear
-  [lv_rmeta_5]  ewi-aor--- linear
+  lv            rwi-a-r\-\-- raid6_nr    0
+  [lv_rimage_0] iwi-aor\-\-- linear      0
+  [lv_rimage_0] iwi-aor\-\-- linear
+  [lv_rimage_1] iwi-aor\-\-- linear      0
+  [lv_rimage_1] iwi-aor\-\-- linear
+  [lv_rimage_2] iwi-aor\-\-- linear      0
+  [lv_rimage_2] iwi-aor\-\-- linear
+  [lv_rimage_3] iwi-aor\-\-- linear      0
+  [lv_rimage_4] iwi-aor\-\-- linear      0
+  [lv_rimage_5] iwi-aor\-\-- linear      0
+  [lv_rmeta_0]  ewi-aor\-\-- linear
+  [lv_rmeta_1]  ewi-aor\-\-- linear
+  [lv_rmeta_2]  ewi-aor\-\-- linear
+  [lv_rmeta_3]  ewi-aor\-\-- linear
+  [lv_rmeta_4]  ewi-aor\-\-- linear
+  [lv_rmeta_5]  ewi-aor\-\-- linear
 .fi
 
 In case the RaidLV should be converted to striped:
 
 .nf
-# lvconvert --type striped tb/lv
+# lvconvert \-\-type striped tb/lv
   Unable to convert LV tb/lv from raid6_nr to striped.
   Converting tb/lv from raid6_nr is directly possible to the following layouts:
     raid6_nc
@@ -1290,55 +1290,55 @@ In case the RaidLV should be converted to striped:
     raid6_rs_6
     raid6_n_6
 
-# lvconvert --type raid6_n_6
+# lvconvert \-\-type raid6_n_6
   Using default stripesize 64.00 KiB.
   Converting raid6_nr LV tb/lv to raid6_n_6.
 Are you sure you want to convert raid6_nr LV tb/lv? [y/n]: y
   Logical volume tb/lv successfully converted.
 
-# lvconvert -y --type striped tb/lv
+# lvconvert -y \-\-type striped tb/lv
   Logical volume tb/lv successfully converted.
 
 [root at vm46 ~]# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type    PE Ranges                                                      DOff
-  lv   -wi-a----- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
-  lv   -wi-a----- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
+  lv   -wi-a\-\-\-\-- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
+  lv   -wi-a\-\-\-\-- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
 .fi
 
 From striped we can convert to raid10
 
 .nf
-# lvconvert -y --type raid10 tb/lv
+# lvconvert -y \-\-type raid10 tb/lv
   Using default stripesize 64.00 KiB.
   Logical volume tb/lv successfully converted.
 
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type   PE Ranges                                                                                   DOff
-  lv   rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  lv   rwi-a-r\-\-- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   WARNING: Cannot find matching striped segment for tb/lv_rimage_3.
   LV            Attr       Type   PE Ranges                                                                                   DOff
-  lv            rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
-  [lv_rimage_0] iwi-aor--- linear /dev/sda:2-32                                                                                                                              0
-  [lv_rimage_0] iwi-aor--- linear /dev/sda:34-35
-  [lv_rimage_1] iwi-aor--- linear /dev/sdaa:2-32                                                                                                                             0
-  [lv_rimage_1] iwi-aor--- linear /dev/sdaa:34-35
-  [lv_rimage_2] iwi-aor--- linear /dev/sdab:2-32                                                                                                                             0
-  [lv_rimage_2] iwi-aor--- linear /dev/sdab:34-35
-  [lv_rimage_3] iwi-XXr--- linear /dev/sdac:3-35                                                                                                                             0
-  [lv_rimage_4] iwi-aor--- linear /dev/sdad:1-33                                                                                                                             0
-  [lv_rimage_5] iwi-aor--- linear /dev/sdae:1-33                                                                                                                             0
-  [lv_rimage_6] iwi-aor--- linear /dev/sdaf:1-33                                                                                                                             0
-  [lv_rimage_7] iwi-aor--- linear /dev/sdag:1-33                                                                                                                             0
-  [lv_rmeta_0]  ewi-aor--- linear /dev/sda:0-0
-  [lv_rmeta_1]  ewi-aor--- linear /dev/sdaa:0-0
-  [lv_rmeta_2]  ewi-aor--- linear /dev/sdab:0-0
-  [lv_rmeta_3]  ewi-aor--- linear /dev/sdac:0-0
-  [lv_rmeta_4]  ewi-aor--- linear /dev/sdad:0-0
-  [lv_rmeta_5]  ewi-aor--- linear /dev/sdae:0-0
-  [lv_rmeta_6]  ewi-aor--- linear /dev/sdaf:0-0
-  [lv_rmeta_7]  ewi-aor--- linear /dev/sdag:0-0
+  lv            rwi-a-r\-\-- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  [lv_rimage_0] iwi-aor\-\-- linear /dev/sda:2-32                                                                                                                              0
+  [lv_rimage_0] iwi-aor\-\-- linear /dev/sda:34-35
+  [lv_rimage_1] iwi-aor\-\-- linear /dev/sdaa:2-32                                                                                                                             0
+  [lv_rimage_1] iwi-aor\-\-- linear /dev/sdaa:34-35
+  [lv_rimage_2] iwi-aor\-\-- linear /dev/sdab:2-32                                                                                                                             0
+  [lv_rimage_2] iwi-aor\-\-- linear /dev/sdab:34-35
+  [lv_rimage_3] iwi-XXr\-\-- linear /dev/sdac:3-35                                                                                                                             0
+  [lv_rimage_4] iwi-aor\-\-- linear /dev/sdad:1-33                                                                                                                             0
+  [lv_rimage_5] iwi-aor\-\-- linear /dev/sdae:1-33                                                                                                                             0
+  [lv_rimage_6] iwi-aor\-\-- linear /dev/sdaf:1-33                                                                                                                             0
+  [lv_rimage_7] iwi-aor\-\-- linear /dev/sdag:1-33                                                                                                                             0
+  [lv_rmeta_0]  ewi-aor\-\-- linear /dev/sda:0-0
+  [lv_rmeta_1]  ewi-aor\-\-- linear /dev/sdaa:0-0
+  [lv_rmeta_2]  ewi-aor\-\-- linear /dev/sdab:0-0
+  [lv_rmeta_3]  ewi-aor\-\-- linear /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor\-\-- linear /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor\-\-- linear /dev/sdae:0-0
+  [lv_rmeta_6]  ewi-aor\-\-- linear /dev/sdaf:0-0
+  [lv_rmeta_7]  ewi-aor\-\-- linear /dev/sdag:0-0
 .fi
 
 raid10 allows to add stripes but can't remove them.
@@ -1353,7 +1353,7 @@ We start with the linear LV.
 .nf
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV   Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
-  lv   -wi-a----- 128.00m linear              1     0        /dev/sda(0)
+  lv   -wi-a\-\-\-\-- 128.00m linear              1     0        /dev/sda(0)
 .fi
 
 Then convert it to a 2-way raid1.
@@ -1364,11 +1364,11 @@ Then convert it to a 2-way raid1.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
-  lv            rwi-a-r--- 128.00m raid1  100.00       2     0        lv_rimage_0(0),lv_rimage_1(0)
-  [lv_rimage_0] iwi-aor--- 128.00m linear              1     0        /dev/sda(0)
-  [lv_rimage_1] iwi-aor--- 128.00m linear              1     0        /dev/sdhx(1)
-  [lv_rmeta_0]  ewi-aor---   4.00m linear              1     0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor---   4.00m linear              1     0        /dev/sdhx(0)
+  lv            rwi-a-r\-\-- 128.00m raid1  100.00       2     0        lv_rimage_0(0),lv_rimage_1(0)
+  [lv_rimage_0] iwi-aor\-\-- 128.00m linear              1     0        /dev/sda(0)
+  [lv_rimage_1] iwi-aor\-\-- 128.00m linear              1     0        /dev/sdhx(1)
+  [lv_rmeta_0]  ewi-aor\-\--   4.00m linear              1     0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor\-\--   4.00m linear              1     0        /dev/sdhx(0)
 .fi
 
 Once the raid1 LV is fully synchronized we convert it to raid5_n (only 2-way raid1
@@ -1377,17 +1377,17 @@ SubLVs at the end and can be converted to striped directly without any additiona
 conversion.
 
 .nf
-# lvconvert -y --ty raid5_n vg/lv
+# lvconvert -y \-\-ty raid5_n vg/lv
   Using default stripesize 64.00 KiB.
   Logical volume vg/lv successfully converted.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe RSize Devices
-  lv            rwi-a-r--- 128.00m raid5_n 100.00       1 64.00k     0 lv_rimage_0(0),lv_rimage_1(0)
-  [lv_rimage_0] iwi-aor--- 128.00m linear               1     0      0 /dev/sda(0)
-  [lv_rimage_1] iwi-aor--- 128.00m linear               1     0      0 /dev/sdhx(1)
-  [lv_rmeta_0]  ewi-aor---   4.00m linear               1     0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor---   4.00m linear               1     0        /dev/sdhx(0)
+  lv            rwi-a-r\-\-- 128.00m raid5_n 100.00       1 64.00k     0 lv_rimage_0(0),lv_rimage_1(0)
+  [lv_rimage_0] iwi-aor\-\-- 128.00m linear               1     0      0 /dev/sda(0)
+  [lv_rimage_1] iwi-aor\-\-- 128.00m linear               1     0      0 /dev/sdhx(1)
+  [lv_rmeta_0]  ewi-aor\-\--   4.00m linear               1     0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor\-\--   4.00m linear               1     0        /dev/sdhx(0)
 .fi
 
 Now we'll change the number of data stripes from 1 to 5 and request 128K stripe size
@@ -1396,7 +1396,7 @@ to the one given).  That additonal space can be used by e.g. growing any contain
 or the LV can be reduced in size after the reshaping conversion has finished.
 
 .nf
-# lvconvert --yes --stripesize 128k --stripes 5 vg/lv
+# lvconvert \-\-yes \-\-stripesize 128k \-\-stripes 5 vg/lv
   Converting stripesize 64.00 KiB of raid5_n LV vg/lv to 128.00 KiB.
   WARNING: Adding stripes to active logical volume vg/lv will grow it from 32 to 160 extents!
   Run "lvresize -l32 vg/lv" to shrink it or use the additional capacity.
@@ -1404,44 +1404,44 @@ or the LV can be reduced in size after the reshaping conversion has finished.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
-  lv            rwi-a-r--- 640.00m raid5_n 100.00       5 128.00k     6 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0),lv_rimage_3(0),lv_rimage_4(0),lv_rimage_5(0)
-  [lv_rimage_0] iwi-aor--- 132.00m linear               1      0      1 /dev/sda(33)
-  [lv_rimage_0] iwi-aor--- 132.00m linear               1      0        /dev/sda(0)
-  [lv_rimage_1] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhx(33)
-  [lv_rimage_1] iwi-aor--- 132.00m linear               1      0        /dev/sdhx(1)
-  [lv_rimage_2] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhw(33)
-  [lv_rimage_2] iwi-aor--- 132.00m linear               1      0        /dev/sdhw(1)
-  [lv_rimage_3] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhv(33)
-  [lv_rimage_3] iwi-aor--- 132.00m linear               1      0        /dev/sdhv(1)
-  [lv_rimage_4] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhu(33)
-  [lv_rimage_4] iwi-aor--- 132.00m linear               1      0        /dev/sdhu(1)
-  [lv_rimage_5] iwi-aor--- 132.00m linear               1      0      1 /dev/sdht(33)
-  [lv_rimage_5] iwi-aor--- 132.00m linear               1      0        /dev/sdht(1)
-  [lv_rmeta_0]  ewi-aor---   4.00m linear               1      0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor---   4.00m linear               1      0        /dev/sdhx(0)
-  [lv_rmeta_2]  ewi-aor---   4.00m linear               1      0        /dev/sdhw(0)
-  [lv_rmeta_3]  ewi-aor---   4.00m linear               1      0        /dev/sdhv(0)
-  [lv_rmeta_4]  ewi-aor---   4.00m linear               1      0        /dev/sdhu(0)
-  [lv_rmeta_5]  ewi-aor---   4.00m linear               1      0        /dev/sdht(0)
+  lv            rwi-a-r\-\-- 640.00m raid5_n 100.00       5 128.00k     6 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0),lv_rimage_3(0),lv_rimage_4(0),lv_rimage_5(0)
+  [lv_rimage_0] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sda(33)
+  [lv_rimage_0] iwi-aor\-\-- 132.00m linear               1      0        /dev/sda(0)
+  [lv_rimage_1] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdhx(33)
+  [lv_rimage_1] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdhx(1)
+  [lv_rimage_2] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdhw(33)
+  [lv_rimage_2] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdhw(1)
+  [lv_rimage_3] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdhv(33)
+  [lv_rimage_3] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdhv(1)
+  [lv_rimage_4] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdhu(33)
+  [lv_rimage_4] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdhu(1)
+  [lv_rimage_5] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdht(33)
+  [lv_rimage_5] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdht(1)
+  [lv_rmeta_0]  ewi-aor\-\--   4.00m linear               1      0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdhx(0)
+  [lv_rmeta_2]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdhw(0)
+  [lv_rmeta_3]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdhv(0)
+  [lv_rmeta_4]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdhu(0)
+  [lv_rmeta_5]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdht(0)
 .fi
 
 Once the conversion has finished we can can convert to striped.
 
 .nf
-[root at vm46 ~]# lvconvert -y --ty striped vg/lv
+[root at vm46 ~]# lvconvert -y \-\-ty striped vg/lv
   Logical volume vg/lv successfully converted.
 
 [root at vm46 ~]# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg|sed 's/  *$//'
   LV   Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
-  lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(33),/dev/sdhx(33),/dev/sdhw(33),/dev/sdhv(33),/dev/sdhu(33)
-  lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
+  lv   -wi-a\-\-\-\-- 640.00m striped              5 128.00k       /dev/sda(33),/dev/sdhx(33),/dev/sdhw(33),/dev/sdhv(33),/dev/sdhu(33)
+  lv   -wi-a\-\-\-\-- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
 .fi
 
 Reversing these steps wil convert a given striped LV to linear.
 
 Mind the fact that stripes are removed thus the capacity of the RaidLV will shrink.
 
-"lvconvert --stripes 1 vg/lv" for converting to 1 stripe will inform upfront about
+"lvconvert \-\-stripes 1 vg/lv" for converting to 1 stripe will inform upfront about
 the reduced size to allow for resizing the content or growing the RaidLV before
 actually converting to 1 stripe.  The \fB\-\-force\fP option is needed to
 allow stripe removing conversions to prevent data loss.
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index 7a26401..7026b24 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -108,7 +108,7 @@ report/buffered
 
 This document does not describe these settings in more detail - if you need
 detailed information, including values which are accepted for the settings,
-please run \fBlvmconfig --type default --withcomments <setting>\fP. There are
+please run \fBlvmconfig \-\-type default \-\-withcomments <setting>\fP. There are
 more configuration settings in addition to the common set listed above, but
 they are specific to either \fBmain report\fP or \fBlog report\fP,
 see \fBmain report specifics\fP and \fBlog report specifics\fP for
@@ -125,25 +125,25 @@ or further specify the report configuration.
 Definition of the set set of fields to use
 .RS
 .IP - 3
---options|-o FieldSet
+\-\-options|-o FieldSet
 .br
 Field set to use. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuratin settings that this option overrides.
 .IP - 3
---options|-o+ FieldSet
+\-\-options|-o+ FieldSet
 .br
 Fields to include to current field set. See \fBmain report specifics\fP\ and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option extends.
 .IP - 3
---options|-o- FieldSet
+\-\-options|-o- FieldSet
 .br
 Fields to exclude from current field set. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option reduces.
 .IP - 3
---options|-o# FieldSet
+\-\-options|-o# FieldSet
 .br
 Compaction of unused fields. Overrides report/compact_output_cols configuration
 setting.
@@ -153,13 +153,13 @@ setting.
 Sorting
 .RS
 .IP - 3
---sort|-O+ FieldSet
+\-\-sort|-O+ FieldSet
 .br
 Fields to sort by in ascending order. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option overrides.
 .IP - 3
---sort|-O- FieldSet
+\-\-sort|-O- FieldSet
 .br
 Fields to sort by in descending order. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about fields sets configured with
@@ -170,7 +170,7 @@ global configuration settings that this options overrides.
 Selection
 .RS
 .IP - 3
---select|-S Selection
+\-\-select|-S Selection
 .br
 Define selection criteria for report output. For \fBlog report\fP, this also
 overrides log/command_log_selection configuration setting, see also
@@ -181,43 +181,43 @@ overrides log/command_log_selection configuration setting, see also
 Changing output format and composition
 .RS
 .IP - 3
---reportformat
+\-\-reportformat
 .br
 Overrides report/output_format configuration setting.
 .IP - 3
---aligned
+\-\-aligned
 .br
 Overrides report/aligned configuration setting.
 .IP - 3
---binary
+\-\-binary
 .br
 Overrides report/binary_values_as_numeric configuration setting.
 .IP - 3
---nameprefixes
+\-\-nameprefixes
 .br
 Overrides report/prefixes configuration setting.
 .IP - 3
---noheadings
+\-\-noheadings
 .br
 Overrides report/noheadings configuration setting.
 .IP - 3
---nosuffix
+\-\-nosuffix
 .br
 Overrides global/suffix configuration setting.
 .IP - 3
---rows
+\-\-rows
 .br
 Overrides report/columns_as_rows configuration setting.
 .IP - 3
---separator
+\-\-separator
 .br
 Overrides report/separator configuration setting.
 .IP - 3
---units
+\-\-units
 .br
 Overrides global/units configuration setting.
 .IP - 3
---unquoted
+\-\-unquoted
 .br
 Overrides report/quoted configuration setting.
 .RE
@@ -226,19 +226,19 @@ Overrides report/quoted configuration setting.
 Special options
 .RS
 .IP - 3
---configreport \fBReportName\fP
+\-\-configreport \fBReportName\fP
 .br
-This defines the \fBReportName\fP for which any subsequent -o|--columns,
--O|--sort or -S|--select applies to. See also \fBmain report specifics\fP
+This defines the \fBReportName\fP for which any subsequent -o|\-\-columns,
+-O|\-\-sort or -S|\-\-select applies to. See also \fBmain report specifics\fP
 and \fBlog report specifics\fP for possible \fBReportName\fP values.
 .IP - 3
---logonly
+\-\-logonly
 .br
 When an LVM command contains both \fBmain report\fP and \fBlog report\fP,
 this option suppresses the \fBmain report\fP output and it causes the
 \fBlog report\fP output to be displayed only.
 .IP - 3
---unbuffered
+\-\-unbuffered
 .br
 Overrides report/bufffered configuration setting.
 .RE
@@ -276,7 +276,7 @@ report/pvs_sort
 .RE
 
 .IP \[bu] 3
-\fBpvseg\fP representing report about Physical Volume Segments (\fBpvs --segments\fP)
+\fBpvseg\fP representing report about Physical Volume Segments (\fBpvs \-\-segments\fP)
 .RS
 .IP - 3
 report/pvseg_cols
@@ -303,7 +303,7 @@ report/lvs_sort
 .RE
 
 .IP \[bu] 3
-\fBseg\fP representing report about Logical Volume Segments (\fBlvs --segments\fP)
+\fBseg\fP representing report about Logical Volume Segments (\fBlvs \-\-segments\fP)
 .RS
 .IP - 3
 report/segs_cols
@@ -355,10 +355,10 @@ groups are combined together. Some of these combinations are not allowed in
 which case LVM will issue an error.
 
 For all main report subtypes except \fBfull\fP, it's not necessary to use
-\fB--configreport ReportName\fP to denote which report any subsequent
+\fB\-\-configreport ReportName\fP to denote which report any subsequent
 \fB-o, -O or -S\fP option applies to as they always apply to the single main
 report type. Currently, \fBlvm fullreport\fP is the only command that
-includes more than one \fBmain report\fP subtype. Therefore, the --configreport
+includes more than one \fBmain report\fP subtype. Therefore, the \-\-configreport
 is particularly suitable for the full report if you need to configure each of
 its subreports in a different way.
 
@@ -387,13 +387,13 @@ log/command_log_selection
 
 .RE
 
-You always need to use \fB--configreport log\fP together with \fB-o|--options,
--O|--sort or -S|--selection\fP to override configuration settings directly on
+You always need to use \fB\-\-configreport log\fP together with \fB-o|\-\-options,
+-O|\-\-sort or -S|\-\-selection\fP to override configuration settings directly on
 command line for \fBlog report\fP. When compared to \fBmain report\fP, in
 addition to usual configuration settings for report fields and sorting, the
 \fBlog report\fP has also configuration option for selection -
 \fBreport/command_log_selection\fP. This configuration setting is provided for
-convenience so it's not necessary to use \fB-S|--select\fP on command line
+convenience so it's not necessary to use \fB-S|\-\-select\fP on command line
 each time an LVM command is executed and we need the same selection criteria
 to be applied for \fBlog report\fP. Default selection criteria used for
 \fBlog report\fP are
@@ -572,7 +572,7 @@ Rreturn code associated with current item.
 .RE
 
 
-You can also run \fB<lvm_command> --configreport log -o help\fP to
+You can also run \fB<lvm_command> \-\-configreport log -o help\fP to
 to display complete list of fields that you may use for the \fBlog report\fP.
 
 .SH Selection
@@ -668,7 +668,7 @@ criteria)
 \fBnumber\fP for integer value
 .IP \[bu] 3
 \fBsize\fP for integer or floating point number with size unit suffix
-(see also \fBlvcreate\fP(8) man page and description for "-L|--size"
+(see also \fBlvcreate\fP(8) man page and description for "-L|\-\-size"
 option for the list of recognized suffixes)
 .IP \[bu] 3
 \fBpercent\fP for floating point number with or without "%" suffix
@@ -818,7 +818,7 @@ including all configuration related to reporting. We will use it throughout
 examples below to display current configuration.
 
 .nf
-# lvmconfig --type full global/units global/suffix \\
+# lvmconfig \-\-type full global/units global/suffix \\
    report/output_format  report/compact_output \\
    report/compact_output_cols report/aligned \\
    report/headings report/separator \\
@@ -854,7 +854,7 @@ type is configured with configuration settings as we already mentioned in
 \fBmain report specifics\fP section in this man page.
 
 .nf
-# lvmconfig --type full report/pvs_cols report/pvs_sort \\
+# lvmconfig \-\-type full report/pvs_cols report/pvs_sort \\
    report/pvsegs_cols report/pvsegs_sort report/vgs_cols \\
    report/vgs_sort report/lvs_cols report/lvs_sort \\
    report/segs_cols report/segs_sort
@@ -875,32 +875,32 @@ segs_sort="vg_name,lv_name,seg_start"
 .nf
 # pvs
   PV         VG Fmt  Attr PSize   PFree 
-  /dev/sda   vg lvm2 a--  100.00m 88.00m
-  /dev/sdb   vg lvm2 a--  100.00m 92.00m
+  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m
+  /dev/sdb   vg lvm2 a\-\-  100.00m 92.00m
 
-# pvs --segments
+# pvs \-\-segments
   PV         VG Fmt  Attr PSize   PFree  Start SSize
-  /dev/sda   vg lvm2 a--  100.00m 88.00m     0     1
-  /dev/sda   vg lvm2 a--  100.00m 88.00m     1     1
-  /dev/sda   vg lvm2 a--  100.00m 88.00m     2     1
-  /dev/sda   vg lvm2 a--  100.00m 88.00m     3    22
-  /dev/sdb   vg lvm2 a--  100.00m 92.00m     0     1
-  /dev/sdb   vg lvm2 a--  100.00m 92.00m     1     1
-  /dev/sdb   vg lvm2 a--  100.00m 92.00m     2    23
+  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m     0     1
+  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m     1     1
+  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m     2     1
+  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m     3    22
+  /dev/sdb   vg lvm2 a\-\-  100.00m 92.00m     0     1
+  /dev/sdb   vg lvm2 a\-\-  100.00m 92.00m     1     1
+  /dev/sdb   vg lvm2 a\-\-  100.00m 92.00m     2    23
 
 # vgs
   VG #PV #LV #SN Attr   VSize   VFree  
-  vg   2   2   0 wz--n- 200.00m 180.00m
+  vg   2   2   0 wz\-\-n- 200.00m 180.00m
 
 # lvs
   LV    VG Attr       LSize Pool Origin Move Log Cpy%Sync Convert
-  lvol0 vg -wi-a----- 4.00m                                    
-  lvol1 vg rwi-a-r--- 4.00m                      100.00          
+  lvol0 vg -wi-a\-\-\-\-- 4.00m                                    
+  lvol1 vg rwi-a-r\-\-- 4.00m                      100.00          
 
-# lvs --segments
+# lvs \-\-segments
   LV    VG Attr       #Str Type   SSize
-  lvol0 vg -wi-a-----    1 linear 4.00m
-  lvol1 vg rwi-a-r---    2 raid1  4.00m
+  lvol0 vg -wi-a\-\-\-\--    1 linear 4.00m
+  lvol1 vg rwi-a-r\-\--    2 raid1  4.00m
 .fi
 
 We will use \fBreport/lvs_cols\fP and \fBreport/lvs_sort\fP configuration
@@ -911,7 +911,7 @@ Also note that in the example below, we don't display the "lv_time" field
 even though we're using it for sorting - this is allowed.
 
 .nf
-# lvmconfig --type full report/lvs_cols report/lvs_sort
+# lvmconfig \-\-type full report/lvs_cols report/lvs_sort
 lvs_cols="lv_name,lv_size,origin,pool_lv,copy_percent"
 lvs_sort="-lv_time"
 
@@ -921,7 +921,7 @@ lvs_sort="-lv_time"
   lvol0 4.00m  
 .fi
 
-You can use \fB-o|--options\fP command line option to override current
+You can use \fB-o|\-\-options\fP command line option to override current
 configuration directly on command line.
 
 .nf
@@ -956,7 +956,7 @@ This way, it's possible to configure different sets of fields to display
 and to sort by for individual reports as well as the full report.
 
 .nf
-# lvmconfig --type full report/pvs_cols_full \\
+# lvmconfig \-\-type full report/pvs_cols_full \\
    report/pvs_sort_full report/pvsegs_cols_full \\
    report/pvsegs_sort_full report/vgs_cols_full \\
    report/vgs_sort_full report/lvs_cols_full \\
@@ -1007,7 +1007,7 @@ output. To enable this feature and to compact all fields, use
 \fBreport/compact_output=1\fP in your configuration.
 
 .nf
-# lvmconfig --type full report/compact_output
+# lvmconfig \-\-type full report/compact_output
 compact_output=1
 
 # lvs
@@ -1021,11 +1021,11 @@ compact_output=1
 .fi
 
 Alternatively, you can define which fields should be compacted by configuring
-\fBreport/compact_output_cols\fP configuration setting (or \fB-o|--options #\fP
+\fBreport/compact_output_cols\fP configuration setting (or \fB-o|\-\-options #\fP
 command line option).
 
 .nf
-# lvmconfig --type full report/compact_output report/compact_output_cols
+# lvmconfig \-\-type full report/compact_output report/compact_output_cols
 compact_output=0
 compact_output_cols="origin"
 
@@ -1050,83 +1050,83 @@ We will use \fBreport/compact_output=1\fP for subsequent examples.
 
 By default, LVM displays sizes in reports in human-readable form which means
 that the most suitable unit is used so it's easy to read. You can use
-\fBreport/units\fP configuration setting (or \fB--units\fP option directly
+\fBreport/units\fP configuration setting (or \fB\-\-units\fP option directly
 on command line) and \fBreport/suffix\fP
-configuration setting (or \fB--nosuffix\fP command line option) to change this.
+configuration setting (or \fB\-\-nosuffix\fP command line option) to change this.
 
 .nf
-# lvs --units b --nosuffix
+# lvs \-\-units b \-\-nosuffix
   LV    LSize   Cpy%Sync
   lvol1 4194304 100.00  
   lvol0 4194304    
 .fi
 
 If you want to configure whether report headings are displayed or not, use
-\fBreport/headings\fP configuration settings (or \fB--noheadings\fP command
+\fBreport/headings\fP configuration settings (or \fB\-\-noheadings\fP command
 line option).
 
 .nf
-# lvs --noheadings
+# lvs \-\-noheadings
   lvol1 4.00m 100.00  
   lvol0 4.00m     
 .fi
 
 In some cases, it may be useful to display report content as key=value pairs
 where key here is actually the field name. Use \fBreport/prefixes\fP
-configuration setting (or \fB--nameprefixes\fP command line option) to switch
+configuration setting (or \fB\-\-nameprefixes\fP command line option) to switch
 between standard output and the key=value output. The key=value pair is the
 output that is suitable for use in scripts and for other tools to parse easily.
 Usually, you also don't want to display headings with the output that has these
 key=value pairs.
 
 .nf
-# lvs --noheadings --nameprefixes
+# lvs \-\-noheadings \-\-nameprefixes
   LVM2_LV_NAME='lvol1' LVM2_LV_SIZE='4.00m' LVM2_COPY_PERCENT='100.00'
   LVM2_LV_NAME='lvol0' LVM2_LV_SIZE='4.00m' LVM2_COPY_PERCENT=''
 .fi
 
 To define whether quotation marks in key=value pairs should be used or not,
-use \fBreport/quoted\fP configuration setting (or \fB--unquoted\fP command
+use \fBreport/quoted\fP configuration setting (or \fB\-\-unquoted\fP command
 line option).
 
 .nf
-# lvs --noheadings --nameprefixes --unquoted
+# lvs \-\-noheadings \-\-nameprefixes \-\-unquoted
   LVM2_LV_NAME=lvol1 LVM2_LV_SIZE=4.00m LVM2_COPY_PERCENT=100.00
   LVM2_LV_NAME=lvol0 LVM2_LV_SIZE=4.00m LVM2_COPY_PERCENT=
 .fi
 
 For easier parsing, you can even transpose the report so each column now
 becomes a row in the output. This is done with \fBreport/output_as_rows\fP
-configuration setting (or \fB--rows\fP command line option).
+configuration setting (or \fB\-\-rows\fP command line option).
 
 .nf
-# lvs --noheadings --nameprefixes --unquoted --rows
+# lvs \-\-noheadings \-\-nameprefixes \-\-unquoted \-\-rows
   LVM2_LV_NAME=lvol1 LVM2_LV_NAME=lvol0
   LVM2_LV_SIZE=4.00m LVM2_LV_SIZE=4.00m
   LVM2_COPY_PERCENT=100.00 LVM2_COPY_PERCENT=
 .fi
 
-Use \fBreport/separator\fP configuration setting (or \fB--separator\fP command
+Use \fBreport/separator\fP configuration setting (or \fB\-\-separator\fP command
 line option) to define your own field separator to use.
 
 .nf
-# lvs --noheadings --nameprefixes --unquoted --separator " | "
+# lvs \-\-noheadings \-\-nameprefixes \-\-unquoted \-\-separator " | "
   LVM2_LV_NAME=lvol1 | LVM2_LV_SIZE=4.00m | LVM2_COPY_PERCENT=100.00
   LVM2_LV_NAME=lvol0 | LVM2_LV_SIZE=4.00m | LVM2_COPY_PERCENT=
 .fi
 
 If you are using your own separator, the columns in the output are not aligned
-by default. Use \fBreport/aligned\fP configuration setting (or \fB--aligned\fP
+by default. Use \fBreport/aligned\fP configuration setting (or \fB\-\-aligned\fP
 command line option) for LVM to add extra spaces in report to align the output
 properly.
 
 .nf
-# lvs --separator " | "
+# lvs \-\-separator " | "
   LV | LSize | Cpy%Sync
   lvol1 | 4.00m | 100.00
   lvol0 | 4.00m | 
 
-# lvs --separator " | " --aligned
+# lvs \-\-separator " | " \-\-aligned
   LV    | LSize | Cpy%Sync
   lvol1 | 4.00m | 100.00  
   lvol0 | 4.00m |         
@@ -1148,7 +1148,7 @@ separator, use \fBreport/list_item_separator\fP configuration setting its
 definition.
 
 .nf
-# lvmconfig --type full report/list_item_separator
+# lvmconfig \-\-type full report/list_item_separator
 list_item_separator=";"
 
 # lvs -o+tags
@@ -1165,7 +1165,7 @@ Format for any of time values displayed in reports can be configured with
 and time is displayed, including timezone.
 
 .nf
-# lvmconfig --type full report/time_format
+# lvmconfig \-\-type full report/time_format
 time_format="%Y-%m-%d %T %z"
 
 # lvs -o+time
@@ -1176,22 +1176,22 @@ time_format="%Y-%m-%d %T %z"
 
 We can change time format in similar way as we do when using \fBdate\fP(1)
 command or \fBstrftime\fP(3) function
-(\fBlvmconfig --type default --withcomments report/time_format\fP will
+(\fBlvmconfig \-\-type default \-\-withcomments report/time_format\fP will
 give you complete list of available formatting options). In the example
 below, we decided to use %s for number of seconds since Epoch (1970-01-01 UTC).
 
 .nf
-# lvmconfig --type full report/time_format
+# lvmconfig \-\-type full report/time_format
 time_format="%s"
 
 # lvs
   LV    Attr       LSize Cpy%Sync LV Tags   CTime                     
-  lvol1 rwi-a-r--- 4.00m 100.00             1472468016                
-  lvol0 -wi-a----- 4.00m          tagA,tagB 1472458517     
+  lvol1 rwi-a-r\-\-- 4.00m 100.00             1472468016                
+  lvol0 -wi-a\-\-\-\-- 4.00m          tagA,tagB 1472458517     
 .fi
 
 The \fBlvs\fP does not display hidden LVs by default - to include these LVs
-in the output, you need to use \fB-a|--all\fP command line option. Names for
+in the output, you need to use \fB-a|\-\-all\fP command line option. Names for
 these hidden LVs are displayed within square brackets.
 
 .nf
@@ -1209,7 +1209,7 @@ You can configure LVM to display the square brackets for hidden LVs or not with
 \fBreport/mark_hidden_devices\fP configuration setting.
 
 .nf
-# lvmconfig --type full report/mark_hidden_devices
+# lvmconfig \-\-type full report/mark_hidden_devices
 mark_hidden_devices=0
 
 # lvs -a
@@ -1254,7 +1254,7 @@ We can change the way how these binary values are displayed with
 \fBreport/binary_values_as_numeric\fP configuration setting.
 
 .nf
-# lvmconfig --type full report/binary_values_as_numeric
+# lvmconfig \-\-type full report/binary_values_as_numeric
 binary_values_as_numeric=1
 
 # lvs -o+lv_active_locally
@@ -1266,12 +1266,12 @@ binary_values_as_numeric=1
 .SS Changing output format
 
 LVM can output reports in different formats - use \fBreport/output_format\fP
-configuration setting (or \fB--reportformat\fP command line option) to swith
+configuration setting (or \fB\-\-reportformat\fP command line option) to swith
 the report output format. Currently, LVM supports \fB"basic"\fP (all the examples
 we used above used this format) and \fB"JSON"\fP output format.
 
 .nf
-# lvs -o lv_name,lv_size --reportformat json
+# lvs -o lv_name,lv_size \-\-reportformat json
   {
       "report": [
           {
@@ -1286,9 +1286,9 @@ we used above used this format) and \fB"JSON"\fP output format.
 
 Note that some configuration settings and command line options have no
 effect with certain report formats. For example, with \fBJSON\fP output,
-it doesn't have any meaning to use \fBreport/aligned\fP (\fB--aligned\fP),
-\fBreport/noheadings\fP (\fB--noheadings\fP), \fBreport/columns_as_rows\fP
-(\fB--rows\fP) or \fBreport/buffered\fP (\fB--unbuffered\fP). All these
+it doesn't have any meaning to use \fBreport/aligned\fP (\fB\-\-aligned\fP),
+\fBreport/noheadings\fP (\fB\-\-noheadings\fP), \fBreport/columns_as_rows\fP
+(\fB\-\-rows\fP) or \fBreport/buffered\fP (\fB\-\-unbuffered\fP). All these
 configuration settings and command line options are ignored if using the
 \fBJSON\fP report output format.
 
@@ -1315,7 +1315,7 @@ look at the bottom of the help output, you can see section about
 # lvs -S help
  ...
 Selection operators
--------------------
+\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--
 Comparison operators:
    =~  - Matching regular expression. [regex]
    !~  - Not matching regular expression. [regex]
@@ -1387,13 +1387,13 @@ together.
 You can also use selection together with processing-oriented commands.
 
 .nf
-# lvchange --addtag test -S 'size < 5000k'
+# lvchange \-\-addtag test -S 'size < 5000k'
   Logical volume vg/lvol1 changed.
   Logical volume vg/lvol0 changed.
   Logical volume vg/lvol3 changed.
   Logical volume vg/lvol4 changed.
 
-# lvchange --deltag test -S 'tags = test'
+# lvchange \-\-deltag test -S 'tags = test'
   Logical volume vg/lvol1 changed.
   Logical volume vg/lvol0 changed.
   Logical volume vg/lvol3 changed.
@@ -1534,7 +1534,7 @@ Time operators have synonyms: ">=" for since, "<=" for until,
 Example below demonstrates using absolute time expression.
 
 .nf
-# lvs -o name,time --config report/time_format="%s"
+# lvs -o name,time \-\-config report/time_format="%s"
   LV    CTime                     
   lvol4 1473433064                
   lvol3 1473433008                
@@ -1601,7 +1601,7 @@ Just like any other report, we can set the set of fields to display
 for this report.
 
 .nf
-# lvmconfig --type full log/report_command_log log/command_log_cols \\
+# lvmconfig \-\-type full log/report_command_log log/command_log_cols \\
    log/command_log_sort log/command_log_selection
 report_command_log=1
 command_log_cols="log_seq_num,log_type,log_context,log_object_type,
@@ -1631,7 +1631,7 @@ log report in the example below where we can see that both LVs lvol0 and
 lvol1 were successfully processed as well as the VG vg they are part of.
 
 .nf
-# lvmconfig --type full log/command_log_selection
+# lvmconfig \-\-type full log/command_log_selection
 command_log_selection="all"
 
 # lvs
@@ -1659,11 +1659,11 @@ command_log_selection="all"
 .SS Handling multiple reports per single command
 
 To configure the log report directly on command line, we need to use
-\fB--configreport\fP option before we start any \fB-o|--options\fP,
-\fB-O|--sort\fP or \fB-S|--select\fP that is targeted for log report.
+\fB\-\-configreport\fP option before we start any \fB-o|\-\-options\fP,
+\fB-O|\-\-sort\fP or \fB-S|\-\-select\fP that is targeted for log report.
 
 .nf
-# lvs -o lv_name,lv_size --configreport log -o log_object_type, \\
+# lvs -o lv_name,lv_size \-\-configreport log -o log_object_type, \\
    log_object_name,log_message,log_ret_code
   Logical Volume
   ==============
@@ -1680,7 +1680,7 @@ To configure the log report directly on command line, we need to use
 .fi
 
 The \fBlvm fullreport\fP, with or without log report, consists of several
-reports - the \fB--configreport\fP is also used to target particular
+reports - the \fB\-\-configreport\fP is also used to target particular
 subreport here.
 
 Below is an extended example with \fBlvm fullreport\fP to illustrate
@@ -1693,12 +1693,12 @@ having "sda" in its name. Also, for the log subreport we define ordering
 to be based on "log_object_type" field.
 
 .nf
-# lvm fullreport --reportformat json \\
-   --configreport vg -o vg_name,vg_size \\
-   --configreport pvseg -o pv_name,pvseg_start \\
+# lvm fullreport \-\-reportformat json \\
+   \-\-configreport vg -o vg_name,vg_size \\
+   \-\-configreport pvseg -o pv_name,pvseg_start \\
                         -S 'pv_name=~sda' \\
-   --configreport seg -o lv_name,seg_start \\
-   --configreport log -o log_object_type,log_object_name \\
+   \-\-configreport seg -o lv_name,seg_start \\
+   \-\-configreport log -o log_object_type,log_object_name \\
                       -O log_object_type \\
                       -S 'log_object_name=lvol0 || \\
                           log_object_name=~sda'
diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 3aea996..6e59bb3 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -53,7 +53,7 @@ command 'vgs -o+systemid'
 A VG will not have a system_id if it was created before this feature was
 added to lvm, or if it was created by a host that did not have a system_id
 defined.  A system_id can be assigned to these VGs by using vgchange
---systemid (see below).
+\-\-systemid (see below).
 
 .IP \[bu] 2
 Two hosts should not be assigned the same system_id.  Doing so defeats
@@ -239,7 +239,7 @@ local {
 In vgcreate, the host running the command assigns its own system_id to the
 new VG.  To override this and set another system_id:
 
-.B vgcreate --systemid
+.B vgcreate \-\-systemid
 .I SystemID VG Devices
 
 Overriding the system_id makes it possible for a host to create a VG that
@@ -247,7 +247,7 @@ it may not be able to use.  Another host with a system_id matching the one
 specified may not recognize the new VG without manually rescanning
 devices.
 
-If the --systemid argument is an empty string (""), the VG is created with
+If the \-\-systemid argument is an empty string (""), the VG is created with
 no system_id, making it accessible to other hosts (see warnings above.)
 
 .SS report/display
@@ -255,11 +255,11 @@ no system_id, making it accessible to other hosts (see warnings above.)
 The system_id of a VG is displayed with the "systemid" reporting option.
 
 Report/display commands ignore foreign VGs by default.  To report foreign
-VGs, the --foreign option can be used.  This causes the VGs to be read
+VGs, the \-\-foreign option can be used.  This causes the VGs to be read
 from disk.  Because lvmetad caching is not used, this option can cause
 poor performance.
 
-.B vgs --foreign -o+systemid
+.B vgs \-\-foreign -o+systemid
 
 When a host with no system_id sees foreign VGs, it warns about them as
 they are skipped.  The host should be assigned a system_id, after which
@@ -271,7 +271,7 @@ vgexport clears the system_id.
 
 Other hosts will continue to see a newly exported VG as foreign because of
 local caching (when lvmetad is used).  Manually updating the local lvmetad
-cache with pvscan --cache will allow a host to recognize the newly
+cache with pvscan \-\-cache will allow a host to recognize the newly
 exported VG.
 
 vgimport sets the VG system_id to the local system_id as determined by
@@ -280,7 +280,7 @@ newly exported VGs.
 
 After vgimport, the exporting host will continue to see the VG as
 exported, and not owned by the new host.  Manually updating the local
-cache with pvscan --cache will allow a host to recognize the newly
+cache with pvscan \-\-cache will allow a host to recognize the newly
 imported VG as foreign.
 
 .SS vgchange
@@ -288,7 +288,7 @@ imported VG as foreign.
 A host can change the system_id of its own VGs, but the command requires
 confirmation because the host may lose access to the VG being changed:
 
-.B vgchange --systemid
+.B vgchange \-\-systemid
 .I SystemID VG
 
 The system_id can be removed from a VG by specifying an empty string ("")
@@ -340,7 +340,7 @@ orphan.  Nothing would automatically prevent the other hosts from using
 the newly allocated PV and corrupting it.  If the other hosts run a
 command to rescan devices, and update lvmetad, they would then recognize
 that the PV has been used by another host.  A command that rescans devices
-could be pvscan --cache, or vgs --foreign.
+could be pvscan \-\-cache, or vgs \-\-foreign.
 
 .SH SEE ALSO
 .BR vgcreate (8),
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index f6f8548..b0e3aa0 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -117,8 +117,8 @@ Create an LV that will hold thin pool metadata.
 
 # lvs
   LV        VG Attr       LSize
-  pool0     vg -wi-a----- 10.00g
-  pool0meta vg -wi-a----- 1.00g
+  pool0     vg -wi-a\-\-\-\-- 10.00g
+  pool0meta vg -wi-a\-\-\-\-- 1.00g
 
 .SS 3. create ThinPoolLV
 
@@ -137,13 +137,13 @@ The new ThinPoolLV takes the previous name of ThinDataLV.
 
 # lvs vg/pool0
   LV    VG Attr       LSize  Pool Origin Data% Meta%
-  pool0 vg twi-a-tz-- 10.00g      0.00   0.00
+  pool0 vg twi-a-tz\-\- 10.00g      0.00   0.00
 
 # lvs \-a
   LV            VG Attr       LSize
-  pool0         vg twi-a-tz-- 10.00g
-  [pool0_tdata] vg Twi-ao---- 10.00g
-  [pool0_tmeta] vg ewi-ao---- 1.00g
+  pool0         vg twi-a-tz\-\- 10.00g
+  [pool0_tdata] vg Twi-ao\-\-\-\- 10.00g
+  [pool0_tmeta] vg ewi-ao\-\-\-\- 1.00g
 
 .SS 4. create ThinLV
 
@@ -152,8 +152,8 @@ Create a new thin LV from the thin pool LV.
 The thin LV is created with a virtual size.
 Multiple new thin LVs may be created in the thin pool.
 Thin LV names must be unique in the VG.
-The '--type thin' option is inferred from the virtual size option.
-The --thinpool argument specifies which thin pool will
+The '\-\-type thin' option is inferred from the virtual size option.
+The \-\-thinpool argument specifies which thin pool will
 contain the ThinLV.
 .fi
 
@@ -171,8 +171,8 @@ Create another thin LV in the same thin pool:
 
 # lvs vg/thin1 vg/thin2
   LV    VG Attr       LSize Pool  Origin Data%
-  thin1 vg Vwi-a-tz-- 1.00t pool0        0.00
-  thin2 vg Vwi-a-tz-- 1.00t pool0        0.00
+  thin1 vg Vwi-a-tz\-\- 1.00t pool0        0.00
+  thin2 vg Vwi-a-tz\-\- 1.00t pool0        0.00
 
 .SS 5. create SnapLV
 
@@ -204,9 +204,9 @@ Create a snapshot of the first snapshot:
 
 # lvs vg/thin1s1 vg/thin1s2 vg/thin1s1s1
   LV        VG Attr       LSize Pool  Origin
-  thin1s1   vg Vwi---tz-k 1.00t pool0 thin1
-  thin1s2   vg Vwi---tz-k 1.00t pool0 thin1
-  thin1s1s1 vg Vwi---tz-k 1.00t pool0 thin1s1
+  thin1s1   vg Vwi\-\--tz-k 1.00t pool0 thin1
+  thin1s2   vg Vwi\-\--tz-k 1.00t pool0 thin1
+  thin1s1s1 vg Vwi\-\--tz-k 1.00t pool0 thin1s1
 
 .SS 6. activate SnapLV
 
@@ -297,9 +297,9 @@ same VG.
 # lvconvert \-\-type thin\-pool vg/pool0
 
 # lvs \-a
-  pool0           vg          twi-a-tz--  10.00g
-  [pool0_tdata]   vg          Twi-ao----  10.00g
-  [pool0_tmeta]   vg          ewi-ao----  16.00m
+  pool0           vg          twi-a-tz\-\-  10.00g
+  [pool0_tdata]   vg          Twi-ao\-\-\-\-  10.00g
+  [pool0_tmeta]   vg          ewi-ao\-\-\-\-  16.00m
 .fi
 
 
@@ -381,10 +381,10 @@ explicitly.
 # lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
 
 # lvs \-a
-  [lvol0_pmspare] vg          ewi-------
-  pool0           vg          twi---tz--
-  [pool0_tdata]   vg          Twi-------
-  [pool0_tmeta]   vg          ewi-------
+  [lvol0_pmspare] vg          ewi\-\-\-\-\-\--
+  pool0           vg          twi\-\--tz\-\-
+  [pool0_tdata]   vg          Twi\-\-\-\-\-\--
+  [pool0_tmeta]   vg          ewi\-\-\-\-\-\--
 .fi
 
 The "Metadata check and repair" section describes the use of
@@ -466,7 +466,7 @@ displayed by lvs:
 .nf
 # lvs vg/thin1s1
   LV         VG  Attr       LSize Pool  Origin
-  thin1s1    vg  Vwi---tz-k 1.00t pool0 thin1
+  thin1s1    vg  Vwi\-\--tz-k 1.00t pool0 thin1
 .fi
 
 This flag causes the snapshot LV to be skipped, i.e. not activated,
@@ -539,7 +539,7 @@ Command to extend thin pool data space:
 1. A thin pool LV is using 26.96% of its data blocks.
 # lvs
   LV    VG           Attr       LSize   Pool  Origin Data%
-  pool0 vg           twi-a-tz--  10.00g               26.96
+  pool0 vg           twi-a-tz\-\-  10.00g               26.96
 
 2. Double the amount of physical space in the thin pool LV.
 # lvextend \-L+10G vg/pool0
@@ -547,7 +547,7 @@ Command to extend thin pool data space:
 3. The percentage of used data blocks is half the previous value.
 # lvs
   LV    VG           Attr       LSize   Pool  Origin Data%
-  pool0 vg           twi-a-tz--  20.00g               13.48
+  pool0 vg           twi-a-tz\-\-  20.00g               13.48
 .fi
 
 Other methods of increasing free data space in a thin pool LV
@@ -579,9 +579,9 @@ Command to extend thin pool metadata space:
 .nf
 # lvs \-a \-oname,attr,size vg
   LV              Attr       LSize
-  pool0           twi-a-tz--  20.00g
-  [pool0_tdata]   Twi-ao----  20.00g
-  [pool0_tmeta]   ewi-ao----  12.00m
+  pool0           twi-a-tz\-\-  20.00g
+  [pool0_tdata]   Twi-ao\-\-\-\-  20.00g
+  [pool0_tmeta]   ewi-ao\-\-\-\-  12.00m
 .fi
 
 3. Double the amount of physical space in the thin metadata LV.
@@ -621,8 +621,8 @@ thin pool.  The fstrim command restores the physical space to the thin pool.
 .nf
 # lvs \-a \-oname,attr,size,pool_lv,origin,data_percent,metadata_percent vg
 LV              Attr       LSize   Pool  Origin Data%  Meta%
-pool0           twi-a-tz--  10.00g               47.01  21.03
-thin1           Vwi-aotz-- 100.00g pool0          2.70
+pool0           twi-a-tz\-\-  10.00g               47.01  21.03
+thin1           Vwi-aotz\-\- 100.00g pool0          2.70
 
 # df \-h /mnt/X
 Filesystem            Size  Used Avail Use% Mounted on
@@ -631,8 +631,8 @@ Filesystem            Size  Used Avail Use% Mounted on
 # dd if=/dev/zero of=/mnt/X/1Gfile bs=4096 count=262144; sync
 
 # lvs
-pool0           vg   twi-a-tz--  10.00g               57.01  25.26
-thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
+pool0           vg   twi-a-tz\-\-  10.00g               57.01  25.26
+thin1           vg   Vwi-aotz\-\- 100.00g pool0          3.70
 
 # df \-h /mnt/X
 /dev/mapper/vg-thin1   99G  2.1G   92G   3% /mnt/X
@@ -640,8 +640,8 @@ thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
 # rm /mnt/X/1Gfile
 
 # lvs
-pool0           vg   twi-a-tz--  10.00g               57.01  25.26
-thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
+pool0           vg   twi-a-tz\-\-  10.00g               57.01  25.26
+thin1           vg   Vwi-aotz\-\- 100.00g pool0          3.70
 
 # df \-h /mnt/X
 /dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
@@ -649,8 +649,8 @@ thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
 # fstrim \-v /mnt/X
 
 # lvs
-pool0           vg   twi-a-tz--  10.00g               47.01  21.03
-thin1           vg   Vwi-aotz-- 100.00g pool0          2.70
+pool0           vg   twi-a-tz\-\-  10.00g               47.01  21.03
+thin1           vg   Vwi-aotz\-\- 100.00g pool0          2.70
 .fi
 
 The "Discard" section covers an option for automatically freeing data
@@ -714,7 +714,7 @@ lvm.conf monitoring setting.
 
 .IP \[bu]
 To activate or create a thin pool LV without interacting with dmeventd,
-the --ignoremonitoring option can be used.  With this option, the command
+the \-\-ignoremonitoring option can be used.  With this option, the command
 will not ask dmeventd to monitor the thin pool LV.
 
 .IP \[bu]
@@ -740,14 +740,14 @@ is all used (see the section "Automatically extend thin pool LV").  If
 thin pool data space is already exhausted, it can still be extended (see
 the section "Manually manage free data space of thin pool LV".)
 
-The behavior of a full thin pool is configurable with the --errorwhenfull
+The behavior of a full thin pool is configurable with the \-\-errorwhenfull
 y|n option to lvcreate or lvchange.  The errorwhenfull setting applies
 only to writes; reading thin LVs can continue even when data space is
 exhausted.
 
 Command to change the handling of a full thin pool:
 .br
-.B lvchange --errorwhenfull {y|n} VG/ThinPoolLV
+.B lvchange \-\-errorwhenfull {y|n} VG/ThinPoolLV
 
 .BR lvm.conf (5)
 .B error_when_full
@@ -799,7 +799,7 @@ the thin pool LV:
 .nf
 # lvs vg/pool0
   LV     VG           Attr       LSize   Pool  Origin Data%
-  pool0  vg           twi-a-tz-- 512.00m              100.00
+  pool0  vg           twi-a-tz\-\- 512.00m              100.00
 .fi
 
 .I causes
@@ -940,9 +940,9 @@ activation {
         thin_pool_autoextend_percent=10
 }
 
-# lvchange --metadataprofile pool0extend vg/pool0
+# lvchange \-\-metadataprofile pool0extend vg/pool0
 
-# lvextend --use-policies vg/pool0
+# lvextend \-\-use-policies vg/pool0
 .fi
 
 .I Notes
@@ -962,7 +962,7 @@ An LV without a profile of its own will inherit the VG profile.
 .IP \[bu] 2
 Remove a profile from an LV using the command:
 .br
-.B lvchange --detachprofile VG/ThinPoolLV.
+.B lvchange \-\-detachprofile VG/ThinPoolLV.
 
 .IP \[bu] 2
 Commands can also have profiles applied to them.  The settings that can be
@@ -1130,8 +1130,8 @@ to read unwritten parts of the thin snapshot.
 
 # lvs vg/lve vg/snaplve
   LV      VG  Attr       LSize  Pool  Origin Data%
-  lve     vg  ori------- 10.00g
-  snaplve vg  Vwi-a-tz-- 10.00g pool0 lve      0.00
+  lve     vg  ori\-\-\-\-\-\-- 10.00g
+  snaplve vg  Vwi-a-tz\-\- 10.00g pool0 lve      0.00
 .fi
 
 
@@ -1163,15 +1163,15 @@ name of ExampleLV.
 # lvcreate \-n lv_example \-L 10G vg
 
 # lvs
-  lv_example      vg          -wi-a-----  10.00g
+  lv_example      vg          -wi-a\-\-\-\--  10.00g
 
 # lvconvert \-\-type thin \-\-thinpool vg/pool0
           \-\-originname lv_external \-\-thin vg/lv_example
 
 # lvs
   LV              VG          Attr       LSize   Pool  Origin
-  lv_example      vg          Vwi-a-tz--  10.00g pool0 lv_external
-  lv_external     vg          ori-------  10.00g
+  lv_example      vg          Vwi-a-tz\-\-  10.00g pool0 lv_external
+  lv_external     vg          ori\-\-\-\-\-\--  10.00g
 .fi
 
 
@@ -1193,12 +1193,12 @@ and combines the two into a thin pool LV.
 
 # lvs vg/pool0
   LV    VG  Attr       LSize Pool Origin Data%
-  pool0 vg  twi-a-tz-- 8.00m               0.00
+  pool0 vg  twi-a-tz\-\- 8.00m               0.00
 
 # lvs \-a
-  pool0           vg          twi-a-tz--   8.00m
-  [pool0_tdata]   vg          Twi-ao----   8.00m
-  [pool0_tmeta]   vg          ewi-ao----   8.00m
+  pool0           vg          twi-a-tz\-\-   8.00m
+  [pool0_tdata]   vg          Twi-ao\-\-\-\-   8.00m
+  [pool0_tmeta]   vg          ewi-ao\-\-\-\-   8.00m
 .fi
 
 
@@ -1232,10 +1232,10 @@ Equivalent to:
 # lvcreate \-L8M \-V2G \-n thin1 \-\-thinpool vg/pool0
 
 # lvs \-a
-  pool0           vg          twi-a-tz--   8.00m
-  [pool0_tdata]   vg          Twi-ao----   8.00m
-  [pool0_tmeta]   vg          ewi-ao----   8.00m
-  thin1           vg          Vwi-a-tz--   2.00g pool0
+  pool0           vg          twi-a-tz\-\-   8.00m
+  [pool0_tdata]   vg          Twi-ao\-\-\-\-   8.00m
+  [pool0_tmeta]   vg          ewi-ao\-\-\-\-   8.00m
+  thin1           vg          Vwi-a-tz\-\-   2.00g pool0
 .fi
 
 
@@ -1260,16 +1260,16 @@ activated.
 .nf
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi-a-tz--  10.00g
-  thin1   vg Vwi-a-tz-- 100.00g pool0
+  pool0   vg twi-a-tz\-\-  10.00g
+  thin1   vg Vwi-a-tz\-\- 100.00g pool0
   thin1s1 vg Vwi-a-tz-k 100.00g pool0 thin1
 
 # lvconvert \-\-merge vg/thin1s1
 
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi-a-tz--  10.00g
-  thin1   vg Vwi-a-tz-- 100.00g pool0
+  pool0   vg twi-a-tz\-\-  10.00g
+  thin1   vg Vwi-a-tz\-\- 100.00g pool0
 .fi
 
 .I Example
@@ -1279,8 +1279,8 @@ Delayed merging of open LVs.
 
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi-a-tz--  10.00g
-  thin1   vg Vwi-aotz-- 100.00g pool0
+  pool0   vg twi-a-tz\-\-  10.00g
+  thin1   vg Vwi-aotz\-\- 100.00g pool0
   thin1s1 vg Vwi-aotz-k 100.00g pool0 thin1
 
 # df
@@ -1302,10 +1302,10 @@ Merging of thin snapshot thin1s1 will occur on next activation.
 
 # lvs \-a vg
   LV              VG   Attr       LSize   Pool  Origin
-  pool0           vg   twi-a-tz--  10.00g
-  [pool0_tdata]   vg   Twi-ao----  10.00g
-  [pool0_tmeta]   vg   ewi-ao----   1.00g
-  thin1           vg   Owi-a-tz-- 100.00g pool0
+  pool0           vg   twi-a-tz\-\-  10.00g
+  [pool0_tdata]   vg   Twi-ao\-\-\-\-  10.00g
+  [pool0_tmeta]   vg   ewi-ao\-\-\-\-   1.00g
+  thin1           vg   Owi-a-tz\-\- 100.00g pool0
   [thin1s1]       vg   Swi-a-tz-k 100.00g pool0 thin1
 
 # lvchange \-an vg/thin1
diff --git a/man/lvreduce.8_des b/man/lvreduce.8_des
index 487954d..d9e840e 100644
--- a/man/lvreduce.8_des
+++ b/man/lvreduce.8_des
@@ -13,6 +13,6 @@ Sizes will be rounded if necessary. For example, the LV size must be an
 exact number of extents, and the size of a striped segment must be a
 multiple of the number of stripes.
 
-In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
+with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 98c0414..cdc02cf 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -23,39 +23,39 @@ Sizes will be rounded if necessary. For example, the LV size must be an
 exact number of extents, and the size of a striped segment must be a
 multiple of the number of stripes.
 
-In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
+with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
 the options section.
 .SH USAGE
-\fBlvreduce\fP \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT] \fILV\fP
+\fBlvreduce\fP \fB-L\fP|\fB\-\-size\fP [\fB-\fP]\fISize\fP[m|UNIT] \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP [\fB-\fP]\fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP [\fB-\fP]\fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-n\fP|\fB--nofsck\fP ]
+[ \fB-n\fP|\fB\-\-nofsck\fP ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--resizefs\fP ]
+[ \fB-r\fP|\fB\-\-resizefs\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -66,71 +66,71 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -139,24 +139,24 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--extents\fP [\fB-\fP]\fINumber\fP[PERCENT]
+\fB-l\fP|\fB\-\-extents\fP [\fB-\fP]\fINumber\fP[PERCENT]
 .br
 Specifies the new size of the LV in logical extents.
-The --size and --extents options are alternate methods of specifying size.
+The \-\-size and \-\-extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 An alternate syntax allows the size to be determined indirectly
@@ -176,34 +176,34 @@ from the current size.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-n\fP|\fB--nofsck\fP
+\fB-n\fP|\fB\-\-nofsck\fP
 .br
 Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use --force to proceed with
+requires it. You may need to use \-\-force to proceed with
 this option.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -212,21 +212,21 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -237,16 +237,16 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-r\fP|\fB--resizefs\fP
+\fB-r\fP|\fB\-\-resizefs\fP
 .br
 Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
 .HP
 .ad l
-\fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT]
+\fB-L\fP|\fB\-\-size\fP [\fB-\fP]\fISize\fP[m|UNIT]
 .br
 Specifies the new size of the LV.
-The --size and --extents options are alternate methods of specifying size.
+The \-\-size and \-\-extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
@@ -255,7 +255,7 @@ from the current size.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -265,20 +265,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -305,7 +305,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 83d733e..40b5657 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -39,27 +39,27 @@ former LV completely.
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nohistory\fP ]
+[    \fB\-\-nohistory\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -70,71 +70,71 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -143,40 +143,40 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--nohistory\fP
+\fB\-\-nohistory\fP
 .br
 Do not record history of LVs being removed.
 This has no effect unless the configuration setting
@@ -184,7 +184,7 @@ metadata/record_lvs_history is enabled.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -193,21 +193,21 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -218,12 +218,12 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -231,7 +231,7 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -241,20 +241,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -279,7 +279,7 @@ in place of a VG, LV or PV.
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
-be omitted if the \fB--select\fP option is used.
+be omitted if the \fB\-\-select\fP option is used.
 No arg appears in this position.
 .HP
 \fIString\fP
@@ -296,7 +296,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 67a9b84..679fe39 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -29,15 +29,15 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -45,71 +45,71 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -118,33 +118,33 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -153,21 +153,21 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -178,7 +178,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -188,20 +188,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -232,7 +232,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvresize.8_des b/man/lvresize.8_des
index dcc42aa..4e80281 100644
--- a/man/lvresize.8_des
+++ b/man/lvresize.8_des
@@ -1,6 +1,6 @@
 lvresize resizes an LV in the same way as lvextend and lvreduce. See
 \fBlvextend\fP(8) and \fBlvreduce\fP(8) for more information.
 
-In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
+with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 0f04b40..eaa2a3f 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -11,132 +11,132 @@ lvresize \- Resize a logical volume
 .br
 .P
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
 .br
 .ad l
- \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--commandprofile\fP \fIString\fP
+    \fB\-\-commandprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--config\fP \fIString\fP
+    \fB\-\-config\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-d\fP|\fB--debug\fP
+ \fB-d\fP|\fB\-\-debug\fP
 .ad b
 .br
 .ad l
-    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
+ \fB-l\fP|\fB\-\-extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
 .ad b
 .br
 .ad l
- \fB-f\fP|\fB--force\fP
+ \fB-f\fP|\fB\-\-force\fP
 .ad b
 .br
 .ad l
- \fB-h\fP|\fB--help\fP
+ \fB-h\fP|\fB\-\-help\fP
 .ad b
 .br
 .ad l
-    \fB--longhelp\fP
+    \fB\-\-longhelp\fP
 .ad b
 .br
 .ad l
- \fB-n\fP|\fB--nofsck\fP
+ \fB-n\fP|\fB\-\-nofsck\fP
 .ad b
 .br
 .ad l
-    \fB--nosync\fP
+    \fB\-\-nosync\fP
 .ad b
 .br
 .ad l
-    \fB--noudevsync\fP
+    \fB\-\-noudevsync\fP
 .ad b
 .br
 .ad l
-    \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
+    \fB\-\-poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
-    \fB--profile\fP \fIString\fP
+    \fB\-\-profile\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-q\fP|\fB--quiet\fP
+ \fB-q\fP|\fB\-\-quiet\fP
 .ad b
 .br
 .ad l
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .ad b
 .br
 .ad l
- \fB-r\fP|\fB--resizefs\fP
+ \fB-r\fP|\fB\-\-resizefs\fP
 .ad b
 .br
 .ad l
- \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
+ \fB-L\fP|\fB\-\-size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
- \fB-i\fP|\fB--stripes\fP \fINumber\fP
+ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP
 .ad b
 .br
 .ad l
- \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
+ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT]
 .ad b
 .br
 .ad l
- \fB-t\fP|\fB--test\fP
+ \fB-t\fP|\fB\-\-test\fP
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+    \fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
 .ad b
 .br
 .ad l
- \fB-v\fP|\fB--verbose\fP
+ \fB-v\fP|\fB\-\-verbose\fP
 .ad b
 .br
 .ad l
-    \fB--version\fP
+    \fB\-\-version\fP
 .ad b
 .br
 .ad l
- \fB-y\fP|\fB--yes\fP
+ \fB-y\fP|\fB\-\-yes\fP
 .ad b
 .SH DESCRIPTION
 lvresize resizes an LV in the same way as lvextend and lvreduce. See
 \fBlvextend\fP(8) and \fBlvreduce\fP(8) for more information.
 
-In the usage section below, \fB--size\fP \fISize\fP can be replaced
-with \fB--extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
+with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
 the options section.
 .SH USAGE
 Resize an LV by a specified size.
 .br
 .P
-\fBlvresize\fP \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT] \fILV\fP
+\fBlvresize\fP \fB-L\fP|\fB\-\-size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT] \fILV\fP
 .br
 .RS 4
 .ad l
-[ \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT] ]
+[ \fB-l\fP|\fB\-\-extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT] ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--resizefs\fP ]
+[ \fB-r\fP|\fB\-\-resizefs\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] ]
+[    \fB\-\-poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -154,7 +154,7 @@ Resize an LV by specified PV extents.
 .br
 .RS 4
 .ad l
-[ \fB-r\fP|\fB--resizefs\fP ]
+[ \fB-r\fP|\fB\-\-resizefs\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -165,7 +165,7 @@ Resize an LV by specified PV extents.
 Resize a pool metadata SubLV by a specified size.
 .br
 .P
-\fBlvresize\fP \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
+\fBlvresize\fP \fB\-\-poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT] \fILV\fP\fI_thinpool\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -180,43 +180,43 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-n\fP|\fB--nofsck\fP ]
+[ \fB-n\fP|\fB\-\-nofsck\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosync\fP ]
+[    \fB\-\-nosync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP ]
+[    \fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP ]
 .ad b
 .RE
 
@@ -224,57 +224,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -295,21 +295,21 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -318,24 +318,24 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
+\fB-l\fP|\fB\-\-extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
 .br
 Specifies the new size of the LV in logical extents.
-The --size and --extents options are alternate methods of specifying size.
+The \-\-size and \-\-extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 An alternate syntax allows the size to be determined indirectly
@@ -355,34 +355,34 @@ from the current size.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-n\fP|\fB--nofsck\fP
+\fB-n\fP|\fB\-\-nofsck\fP
 .br
 Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use --force to proceed with
+requires it. You may need to use \-\-force to proceed with
 this option.
 .ad b
 .HP
 .ad l
-\fB--nosync\fP
+\fB\-\-nosync\fP
 .br
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
@@ -399,7 +399,7 @@ and thus do not support initial synchronization.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -408,7 +408,7 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
+\fB\-\-poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
 Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
@@ -416,21 +416,21 @@ the value is added to the current size.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -441,16 +441,16 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-r\fP|\fB--resizefs\fP
+\fB-r\fP|\fB\-\-resizefs\fP
 .br
 Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
 .HP
 .ad l
-\fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
+\fB-L\fP|\fB\-\-size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
 .br
 Specifies the new size of the LV.
-The --size and --extents options are alternate methods of specifying size.
+The \-\-size and \-\-extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
@@ -459,12 +459,12 @@ from the current size.
 .ad b
 .HP
 .ad l
-\fB-i\fP|\fB--stripes\fP \fINumber\fP
+\fB-i\fP|\fB\-\-stripes\fP \fINumber\fP
 .br
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
-the stripe size (see --stripesize). This does not change existing
+the stripe size (see \-\-stripesize). This does not change existing
 allocated space, but only applies to space being allocated by the command.
 When creating a RAID 4/5/6 LV, this number does not include the extra
 devices that are required for parity. The largest number depends on
@@ -476,14 +476,14 @@ see lvm.conf allocation/raid_stripe_all_devices.
 .ad b
 .HP
 .ad l
-\fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
+\fB-I\fP|\fB\-\-stripesize\fP \fISize\fP[k|UNIT]
 .br
 The amount of data that is written to one device before
 moving to the next in a striped LV.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -493,7 +493,7 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
+\fB\-\-type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
 .br
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
@@ -503,25 +503,25 @@ For performance caching (\fBcache\fP, \fBcache-pool\fP) see \fBlvmcache\fP(7).
 For copy-on-write snapshots (\fBsnapshot\fP) see usage definitions.
 Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
-(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
+(e.g. \-\-stripes, \-\-mirrors, \-\-snapshot, \-\-virtualsize, \-\-thin, \-\-cache).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -560,7 +560,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 76c25a5..3d0d02c 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -16,111 +16,111 @@ lvs produces formatted output about LVs.
 .br
 .RS 4
 .ad l
-[ \fB-H\fP|\fB--history\fP ]
+[ \fB-H\fP|\fB\-\-history\fP ]
 .ad b
 .br
 .ad l
-[ \fB-a\fP|\fB--all\fP ]
+[ \fB-a\fP|\fB\-\-all\fP ]
 .ad b
 .br
 .ad l
-[ \fB-o\fP|\fB--options\fP \fIString\fP ]
+[ \fB-o\fP|\fB\-\-options\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-O\fP|\fB--sort\fP \fIString\fP ]
+[ \fB-O\fP|\fB\-\-sort\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--segments\fP ]
+[    \fB\-\-segments\fP ]
 .ad b
 .br
 .ad l
-[    \fB--aligned\fP ]
+[    \fB\-\-aligned\fP ]
 .ad b
 .br
 .ad l
-[    \fB--binary\fP ]
+[    \fB\-\-binary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
+[    \fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
 .ad b
 .br
 .ad l
-[    \fB--foreign\fP ]
+[    \fB\-\-foreign\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--logonly\fP ]
+[    \fB\-\-logonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nameprefixes\fP ]
+[    \fB\-\-nameprefixes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noheadings\fP ]
+[    \fB\-\-noheadings\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nolocking\fP ]
+[    \fB\-\-nolocking\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosuffix\fP ]
+[    \fB\-\-nosuffix\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--rows\fP ]
+[    \fB\-\-rows\fP ]
 .ad b
 .br
 .ad l
-[    \fB--separator\fP \fIString\fP ]
+[    \fB\-\-separator\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--shared\fP ]
+[    \fB\-\-shared\fP ]
 .ad b
 .br
 .ad l
-[    \fB--trustcache\fP ]
+[    \fB\-\-trustcache\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unbuffered\fP ]
+[    \fB\-\-unbuffered\fP ]
 .ad b
 .br
 .ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
+[    \fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unquoted\fP ]
+[    \fB\-\-unquoted\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -134,63 +134,63 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--aligned\fP
+\fB\-\-aligned\fP
 .br
-Use with --separator to align the output columns
+Use with \-\-separator to align the output columns
 .ad b
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
@@ -198,7 +198,7 @@ which are not independently accessible, e.g. not mountable.
 .ad b
 .HP
 .ad l
-\fB--binary\fP
+\fB\-\-binary\fP
 .br
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
@@ -206,14 +206,14 @@ the "unknown" value which denotes that the value could not be determined).
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -222,40 +222,40 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
+\fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--foreign\fP
+\fB\-\-foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-H\fP|\fB--history\fP
+\fB-H\fP|\fB\-\-history\fP
 .br
 Include historical LVs in the output.
 (This has no effect unless LVs were removed while
@@ -263,61 +263,61 @@ lvm.conf metadata/record_lvs_history was enabled.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--logonly\fP
+\fB\-\-logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--nameprefixes\fP
+\fB\-\-nameprefixes\fP
 .br
 Add an "LVM2_" prefix plus the field name to the output. Useful
-with --noheadings to produce a list of field=value pairs that can
+with \-\-noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
 .ad b
 .HP
 .ad l
-\fB--noheadings\fP
+\fB\-\-noheadings\fP
 .br
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--nolocking\fP
+\fB\-\-nolocking\fP
 .br
 Disable locking.
 .ad b
 .HP
 .ad l
-\fB--nosuffix\fP
+\fB\-\-nosuffix\fP
 .br
-Suppress the suffix on output sizes. Use with --units
+Suppress the suffix on output sizes. Use with \-\-units
 (except h and H) if processing the output.
 .ad b
 .HP
 .ad l
-\fB-o\fP|\fB--options\fP \fIString\fP
+\fB-o\fP|\fB\-\-options\fP \fIString\fP
 .br
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
@@ -339,7 +339,7 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -348,21 +348,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -376,7 +376,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -387,24 +387,24 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--rows\fP
+\fB\-\-rows\fP
 .br
 Output columns as rows.
 .ad b
 .HP
 .ad l
-\fB--segments\fP
+\fB\-\-segments\fP
 .br
 Use default columns that emphasize segment information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -412,13 +412,13 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB--separator\fP \fIString\fP
+\fB\-\-separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--shared\fP
+\fB\-\-shared\fP
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
@@ -426,14 +426,14 @@ See lvmlockd(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
-\fB-O\fP|\fB--sort\fP \fIString\fP
+\fB-O\fP|\fB\-\-sort\fP \fIString\fP
 .br
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -443,50 +443,50 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--trustcache\fP
+\fB\-\-trustcache\fP
 .br
 Avoids certain device scanning during command processing. Do not use.
 .ad b
 .HP
 .ad l
-\fB--unbuffered\fP
+\fB\-\-unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
+\fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
-Custom units can be specified, e.g. --units 3M.
+Custom units can be specified, e.g. \-\-units 3M.
 .ad b
 .HP
 .ad l
-\fB--unquoted\fP
+\fB\-\-unquoted\fP
 .br
-When used with --nameprefixes, output values in the field=value
+When used with \-\-nameprefixes, output values in the field=value
 pairs are not quoted.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -522,7 +522,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index f01631b..74c43c0 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -20,14 +20,14 @@ comprehensive information about LVs.
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--all\fP ]
+[ \fB-a\fP|\fB\-\-all\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
 .RE
 .br
 
-\fBlvscan\fP \fB--cache\fP
+\fBlvscan\fP \fB\-\-cache\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -41,23 +41,23 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-b\fP|\fB--blockdevice\fP ]
+[ \fB-b\fP|\fB\-\-blockdevice\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -65,57 +65,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
@@ -123,26 +123,26 @@ which are not independently accessible, e.g. not mountable.
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--blockdevice\fP
+\fB-b\fP|\fB\-\-blockdevice\fP
 .br
 No longer used.
 .ad b
 .HP
 .ad l
-\fB--cache\fP
+\fB\-\-cache\fP
 .br
 Scan the devices used by an LV and send the metadata to lvmetad.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -151,40 +151,40 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -193,21 +193,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -221,7 +221,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -232,7 +232,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -242,20 +242,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -282,7 +282,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index db9cc95..ba7e7ca 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -15,27 +15,27 @@ Change properties of all PVs.
 .P
 \fBpvchange\fP
 .RS 4
-( \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP,
+( \fB-x\fP|\fB\-\-allocatable\fP \fBy\fP|\fBn\fP,
 .ad b
 .br
 .ad l
-  \fB-u\fP|\fB--uuid\fP,
+  \fB-u\fP|\fB\-\-uuid\fP,
 .ad b
 .br
 .ad l
-  \fB-a\fP|\fB--all\fP,
+  \fB-a\fP|\fB\-\-all\fP,
 .ad b
 .br
 .ad l
-     \fB--addtag\fP \fITag\fP,
+     \fB\-\-addtag\fP \fITag\fP,
 .ad b
 .br
 .ad l
-     \fB--deltag\fP \fITag\fP,
+     \fB\-\-deltag\fP \fITag\fP,
 .ad b
 .br
 .ad l
-     \fB--metadataignore\fP \fBy\fP|\fBn\fP )
+     \fB\-\-metadataignore\fP \fBy\fP|\fBn\fP )
 .RE
 .br
 .RS 4
@@ -48,23 +48,23 @@ Change properties of specified PVs.
 .P
 \fBpvchange\fP
 .RS 4
-( \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP,
+( \fB-x\fP|\fB\-\-allocatable\fP \fBy\fP|\fBn\fP,
 .ad b
 .br
 .ad l
-  \fB-u\fP|\fB--uuid\fP,
+  \fB-u\fP|\fB\-\-uuid\fP,
 .ad b
 .br
 .ad l
-     \fB--addtag\fP \fITag\fP,
+     \fB\-\-addtag\fP \fITag\fP,
 .ad b
 .br
 .ad l
-     \fB--deltag\fP \fITag\fP,
+     \fB\-\-deltag\fP \fITag\fP,
 .ad b
 .br
 .ad l
-     \fB--metadataignore\fP \fBy\fP|\fBn\fP )
+     \fB\-\-metadataignore\fP \fBy\fP|\fBn\fP )
 .RE
 .RS 4
  \fIPV\fP|\fISelect\fP ...
@@ -72,7 +72,7 @@ Change properties of specified PVs.
 .br
 .RS 4
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -83,23 +83,23 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-u\fP|\fB--uuid\fP ]
+[ \fB-u\fP|\fB\-\-uuid\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -107,89 +107,89 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--addtag\fP \fITag\fP
+\fB\-\-addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 .ad b
 .HP
 .ad l
-\fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP
+\fB-x\fP|\fB\-\-allocatable\fP \fBy\fP|\fBn\fP
 .br
 Enable or disable allocation of physical extents on this PV.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -198,54 +198,54 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--deltag\fP \fITag\fP
+\fB\-\-deltag\fP \fITag\fP
 .br
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--metadataignore\fP \fBy\fP|\fBn\fP
+\fB\-\-metadataignore\fP \fBy\fP|\fBn\fP
 .br
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
@@ -254,21 +254,21 @@ If no, lvm will store metadata on the PV.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -279,12 +279,12 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -292,7 +292,7 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -302,26 +302,26 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-u\fP|\fB--uuid\fP
+\fB-u\fP|\fB\-\-uuid\fP
 .br
 Generate new random UUID for specified PVs.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -342,7 +342,7 @@ Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\f
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
-be omitted if the \fB--select\fP option is used.
+be omitted if the \fB\-\-select\fP option is used.
 No arg appears in this position.
 .HP
 \fIString\fP
@@ -359,7 +359,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index ff08c45..f368a09 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -14,7 +14,7 @@ pvck checks the LVM metadata for consistency on PVs.
 .br
 .RS 4
 .ad l
-[    \fB--labelsector\fP \fINumber\fP ]
+[    \fB\-\-labelsector\fP \fINumber\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -25,64 +25,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -91,27 +91,27 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--labelsector\fP \fINumber\fP
+\fB\-\-labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
@@ -120,27 +120,27 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -150,20 +150,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -195,7 +195,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 3a37bfa..9eb62df 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -34,63 +34,63 @@ normally prevent it, e.g. if the PV is already in a VG.
 .br
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
-[ \fB-u\fP|\fB--uuid\fP \fIString\fP ]
+[ \fB-u\fP|\fB\-\-uuid\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--dataalignment\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-dataalignment\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--bootloaderareasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-bootloaderareasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--labelsector\fP \fINumber\fP ]
+[    \fB\-\-labelsector\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-metadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--metadataignore\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-metadataignore\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--norestorefile\fP ]
+[    \fB\-\-norestorefile\fP ]
 .ad b
 .br
 .ad l
-[    \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-setphysicalvolumesize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--restorefile\fP \fIString\fP ]
+[    \fB\-\-restorefile\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -101,78 +101,78 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
+\fB\-\-bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
 Create a separate bootloader area of specified size besides PV's data
 area. The bootloader area is an area of reserved space on the PV from
 which LVM will not allocate any extents and it's kept untouched. This is
 primarily aimed for use with bootloaders to embed their own data or metadata.
-The start of the bootloader area is always aligned, see also --dataalignment
-and --dataalignmentoffset. The bootloader area size may eventually
+The start of the bootloader area is always aligned, see also \-\-dataalignment
+and \-\-dataalignmentoffset. The bootloader area size may eventually
 end up increased due to the alignment, but it's never less than the
 size that is requested. To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -181,50 +181,50 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--dataalignment\fP \fISize\fP[k|UNIT]
+\fB\-\-dataalignment\fP \fISize\fP[k|UNIT]
 .br
 Align the start of the data to a multiple of this number.
 Also specify an appropriate Physical Extent size when creating a VG.
 To see the location of the first Physical Extent of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
-See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
+See lvm.conf/data_alignment_offset_detection and \-\-dataalignmentoffset.
 .ad b
 .HP
 .ad l
-\fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
+\fB\-\-dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 Shift the start of the data area by this additional offset.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--labelsector\fP \fINumber\fP
+\fB\-\-labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
@@ -233,13 +233,13 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--metadataignore\fP \fBy\fP|\fBn\fP
+\fB\-\-metadataignore\fP \fBy\fP|\fBn\fP
 .br
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
@@ -248,14 +248,14 @@ If no, lvm will store metadata on the PV.
 .ad b
 .HP
 .ad l
-\fB--metadatasize\fP \fISize\fP[m|UNIT]
+\fB\-\-metadatasize\fP \fISize\fP[m|UNIT]
 .br
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
@@ -264,21 +264,21 @@ can be used for accessing old data.
 .ad b
 .HP
 .ad l
-\fB--norestorefile\fP
+\fB\-\-norestorefile\fP
 .br
-In conjunction with --uuid, this allows a uuid to be specified
+In conjunction with \-\-uuid, this allows a uuid to be specified
 without also requiring that a backup of the metadata be provided.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+\fB\-\-[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
@@ -291,14 +291,14 @@ on the ability to use vgsplit later.)
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -309,9 +309,9 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--restorefile\fP \fIString\fP
+\fB\-\-restorefile\fP \fIString\fP
 .br
-In conjunction with --uuid, this reads the file (produced by
+In conjunction with \-\-uuid, this reads the file (produced by
 vgcfgbackup), extracts the location and size of the data on the PV,
 and ensures that the metadata produced by the program is consistent
 with the contents of the file, i.e. the physical extents will be in
@@ -321,14 +321,14 @@ areas. Use with care.
 .ad b
 .HP
 .ad l
-\fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
+\fB\-\-setphysicalvolumesize\fP \fISize\fP[m|UNIT]
 .br
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -338,33 +338,33 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-u\fP|\fB--uuid\fP \fIString\fP
+\fB-u\fP|\fB\-\-uuid\fP \fIString\fP
 .br
 Specify a UUID for the device.
 Without this option, a random UUID is generated.
 This option is needed before restoring a backup of LVM metadata
 onto a replacement device; see vgcfgrestore(8). As such, use of
---restorefile is compulsory unless the --norestorefile is used.
+\-\-restorefile is compulsory unless the \-\-norestorefile is used.
 All PVs must have unique UUIDs, and LVM will prevent certain operations
 if multiple devices are seen with the same UUID.
 See vgimportclone(8) for more information.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -372,11 +372,11 @@ answer yes. Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+\fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .br
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
---restorefile or --uuid are specified.
+\-\-restorefile or \-\-uuid are specified.
 .ad b
 .SH VARIABLES
 .HP
@@ -404,7 +404,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 2be292a..efb636a 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -20,95 +20,95 @@ and more, using a more compact and configurable output format.
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--all\fP ]
+[ \fB-a\fP|\fB\-\-all\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--colon\fP ]
+[ \fB-c\fP|\fB\-\-colon\fP ]
 .ad b
 .br
 .ad l
-[ \fB-C\fP|\fB--columns\fP ]
+[ \fB-C\fP|\fB\-\-columns\fP ]
 .ad b
 .br
 .ad l
-[ \fB-m\fP|\fB--maps\fP ]
+[ \fB-m\fP|\fB\-\-maps\fP ]
 .ad b
 .br
 .ad l
-[ \fB-o\fP|\fB--options\fP \fIString\fP ]
+[ \fB-o\fP|\fB\-\-options\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-s\fP|\fB--short\fP ]
+[ \fB-s\fP|\fB\-\-short\fP ]
 .ad b
 .br
 .ad l
-[ \fB-O\fP|\fB--sort\fP \fIString\fP ]
+[ \fB-O\fP|\fB\-\-sort\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--aligned\fP ]
+[    \fB\-\-aligned\fP ]
 .ad b
 .br
 .ad l
-[    \fB--binary\fP ]
+[    \fB\-\-binary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
+[    \fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
 .ad b
 .br
 .ad l
-[    \fB--foreign\fP ]
+[    \fB\-\-foreign\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--logonly\fP ]
+[    \fB\-\-logonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noheadings\fP ]
+[    \fB\-\-noheadings\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosuffix\fP ]
+[    \fB\-\-nosuffix\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--separator\fP \fIString\fP ]
+[    \fB\-\-separator\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--shared\fP ]
+[    \fB\-\-shared\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unbuffered\fP ]
+[    \fB\-\-unbuffered\fP ]
 .ad b
 .br
 .ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
+[    \fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -122,70 +122,70 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--aligned\fP
+\fB\-\-aligned\fP
 .br
-Use with --separator to align the output columns
+Use with \-\-separator to align the output columns
 .ad b
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
 .ad b
 .HP
 .ad l
-\fB--binary\fP
+\fB\-\-binary\fP
 .br
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
@@ -193,28 +193,28 @@ the "unknown" value which denotes that the value could not be determined).
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--colon\fP
+\fB-c\fP|\fB\-\-colon\fP
 .br
 Generate colon separated output for easier parsing in scripts or programs.
 Also see vgs(8) which provides considerably more control over the output.
 .ad b
 .HP
 .ad l
-\fB-C\fP|\fB--columns\fP
+\fB-C\fP|\fB\-\-columns\fP
 .br
 Display output in columns, the equivalent of vgs(8).
 Options listed are the same as options given in vgs(8).
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -223,86 +223,86 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
+\fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--foreign\fP
+\fB\-\-foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--logonly\fP
+\fB\-\-logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-m\fP|\fB--maps\fP
+\fB-m\fP|\fB\-\-maps\fP
 .br
 Display the mapping of physical extents to LVs and logical extents.
 .ad b
 .HP
 .ad l
-\fB--noheadings\fP
+\fB\-\-noheadings\fP
 .br
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--nosuffix\fP
+\fB\-\-nosuffix\fP
 .br
-Suppress the suffix on output sizes. Use with --units
+Suppress the suffix on output sizes. Use with \-\-units
 (except h and H) if processing the output.
 .ad b
 .HP
 .ad l
-\fB-o\fP|\fB--options\fP \fIString\fP
+\fB-o\fP|\fB\-\-options\fP \fIString\fP
 .br
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
@@ -324,21 +324,21 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -352,7 +352,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -363,12 +363,12 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -376,13 +376,13 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB--separator\fP \fIString\fP
+\fB\-\-separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--shared\fP
+\fB\-\-shared\fP
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
@@ -390,20 +390,20 @@ See lvmlockd(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
-\fB-s\fP|\fB--short\fP
+\fB-s\fP|\fB\-\-short\fP
 .br
 Only display the size of the given PVs.
 .ad b
 .HP
 .ad l
-\fB-O\fP|\fB--sort\fP \fIString\fP
+\fB-O\fP|\fB\-\-sort\fP \fIString\fP
 .br
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -413,37 +413,37 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--unbuffered\fP
+\fB\-\-unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
+\fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
-Custom units can be specified, e.g. --units 3M.
+Custom units can be specified, e.g. \-\-units 3M.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -480,7 +480,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index e7bc556..f8a8b5c 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -33,27 +33,27 @@ Move PV extents.
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-n\fP|\fB--name\fP \fILV\fP ]
+[ \fB-n\fP|\fB\-\-name\fP \fILV\fP ]
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--atomic\fP ]
+[    \fB\-\-atomic\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -77,15 +77,15 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-b\fP|\fB--background\fP ]
+[ \fB-b\fP|\fB\-\-background\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+[ \fB-i\fP|\fB\-\-interval\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--abort\fP ]
+[    \fB\-\-abort\fP ]
 .ad b
 .RE
 
@@ -93,66 +93,66 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--abort\fP
+\fB\-\-abort\fP
 .br
 Abort any pvmove operations in progress. If a pvmove was started
-with the --atomic option, then all LVs will remain on the source PV.
+with the \-\-atomic option, then all LVs will remain on the source PV.
 Otherwise, segments that have been moved will remain on the
 destination PV, while unmoved segments will remain on the source PV.
 .ad b
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -173,21 +173,21 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB--atomic\fP
+\fB\-\-atomic\fP
 .br
 Makes a pvmove operation atomic, ensuring that all affected LVs are
 moved to the destination PV, or none are if the operation is aborted.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP
+\fB-b\fP|\fB\-\-background\fP
 .br
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
@@ -195,14 +195,14 @@ background.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -211,45 +211,45 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-i\fP|\fB--interval\fP \fINumber\fP
+\fB-i\fP|\fB\-\-interval\fP \fINumber\fP
 .br
 Report progress at regular intervals.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-n\fP|\fB--name\fP \fIString\fP
+\fB-n\fP|\fB\-\-name\fP \fIString\fP
 .br
 Move only the extents belonging to the named LV.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -258,21 +258,21 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -283,7 +283,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -293,20 +293,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -338,7 +338,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 0cc9302..aca7c6b 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -20,11 +20,11 @@ an existing VG. Normally, \fBvgreduce\fP(8) should be used instead.
 .br
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -35,64 +35,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -101,54 +101,54 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -159,7 +159,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -169,20 +169,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -214,7 +214,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 76f3453..6a8f496 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -15,11 +15,11 @@ LVs allocated on it.
 .br
 .RS 4
 .ad l
-[    \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-setphysicalvolumesize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -30,64 +30,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -96,47 +96,47 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -147,14 +147,14 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
+\fB\-\-setphysicalvolumesize\fP \fISize\fP[m|UNIT]
 .br
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -164,20 +164,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -209,7 +209,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 905ccce..b9b36d6 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -16,107 +16,107 @@ pvs produces formatted output about PVs.
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--all\fP ]
+[ \fB-a\fP|\fB\-\-all\fP ]
 .ad b
 .br
 .ad l
-[ \fB-o\fP|\fB--options\fP \fIString\fP ]
+[ \fB-o\fP|\fB\-\-options\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-O\fP|\fB--sort\fP \fIString\fP ]
+[ \fB-O\fP|\fB\-\-sort\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--segments\fP ]
+[    \fB\-\-segments\fP ]
 .ad b
 .br
 .ad l
-[    \fB--aligned\fP ]
+[    \fB\-\-aligned\fP ]
 .ad b
 .br
 .ad l
-[    \fB--binary\fP ]
+[    \fB\-\-binary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
+[    \fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
 .ad b
 .br
 .ad l
-[    \fB--foreign\fP ]
+[    \fB\-\-foreign\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--logonly\fP ]
+[    \fB\-\-logonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nameprefixes\fP ]
+[    \fB\-\-nameprefixes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noheadings\fP ]
+[    \fB\-\-noheadings\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nolocking\fP ]
+[    \fB\-\-nolocking\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosuffix\fP ]
+[    \fB\-\-nosuffix\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--rows\fP ]
+[    \fB\-\-rows\fP ]
 .ad b
 .br
 .ad l
-[    \fB--separator\fP \fIString\fP ]
+[    \fB\-\-separator\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--shared\fP ]
+[    \fB\-\-shared\fP ]
 .ad b
 .br
 .ad l
-[    \fB--trustcache\fP ]
+[    \fB\-\-trustcache\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unbuffered\fP ]
+[    \fB\-\-unbuffered\fP ]
 .ad b
 .br
 .ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
+[    \fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unquoted\fP ]
+[    \fB\-\-unquoted\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -130,70 +130,70 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--aligned\fP
+\fB\-\-aligned\fP
 .br
-Use with --separator to align the output columns
+Use with \-\-separator to align the output columns
 .ad b
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
 .ad b
 .HP
 .ad l
-\fB--binary\fP
+\fB\-\-binary\fP
 .br
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
@@ -201,14 +201,14 @@ the "unknown" value which denotes that the value could not be determined).
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -217,94 +217,94 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
+\fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--foreign\fP
+\fB\-\-foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--logonly\fP
+\fB\-\-logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--nameprefixes\fP
+\fB\-\-nameprefixes\fP
 .br
 Add an "LVM2_" prefix plus the field name to the output. Useful
-with --noheadings to produce a list of field=value pairs that can
+with \-\-noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
 .ad b
 .HP
 .ad l
-\fB--noheadings\fP
+\fB\-\-noheadings\fP
 .br
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--nolocking\fP
+\fB\-\-nolocking\fP
 .br
 Disable locking.
 .ad b
 .HP
 .ad l
-\fB--nosuffix\fP
+\fB\-\-nosuffix\fP
 .br
-Suppress the suffix on output sizes. Use with --units
+Suppress the suffix on output sizes. Use with \-\-units
 (except h and H) if processing the output.
 .ad b
 .HP
 .ad l
-\fB-o\fP|\fB--options\fP \fIString\fP
+\fB-o\fP|\fB\-\-options\fP \fIString\fP
 .br
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
@@ -326,7 +326,7 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -335,21 +335,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -363,7 +363,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -374,13 +374,13 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--rows\fP
+\fB\-\-rows\fP
 .br
 Output columns as rows.
 .ad b
 .HP
 .ad l
-\fB--segments\fP
+\fB\-\-segments\fP
 .br
 Produces one line of output for each contiguous allocation of space on each
 PV, showing the start (pvseg_start) and length (pvseg_size) in units of
@@ -388,12 +388,12 @@ physical extents.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -401,13 +401,13 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB--separator\fP \fIString\fP
+\fB\-\-separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--shared\fP
+\fB\-\-shared\fP
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
@@ -415,14 +415,14 @@ See lvmlockd(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
-\fB-O\fP|\fB--sort\fP \fIString\fP
+\fB-O\fP|\fB\-\-sort\fP \fIString\fP
 .br
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -432,50 +432,50 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--trustcache\fP
+\fB\-\-trustcache\fP
 .br
 Avoids certain device scanning during command processing. Do not use.
 .ad b
 .HP
 .ad l
-\fB--unbuffered\fP
+\fB\-\-unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
+\fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
-Custom units can be specified, e.g. --units 3M.
+Custom units can be specified, e.g. \-\-units 3M.
 .ad b
 .HP
 .ad l
-\fB--unquoted\fP
+\fB\-\-unquoted\fP
 .br
-When used with --nameprefixes, output values in the field=value
+When used with \-\-nameprefixes, output values in the field=value
 pairs are not quoted.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -512,7 +512,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/pvscan.8_des b/man/pvscan.8_des
index 1a24a3d..14551ce 100644
--- a/man/pvscan.8_des
+++ b/man/pvscan.8_des
@@ -38,7 +38,7 @@ read the named devices.
 LVM udev rules and systemd services are used to initiate automatic device
 scanning.
 .IP \[bu] 2
-To prevent devices from being scanned by pvscan --cache, add them
+To prevent devices from being scanned by pvscan \-\-cache, add them
 to
 .BR lvm.conf (5)
 .B devices/global_filter.
@@ -46,7 +46,7 @@ The devices/filter setting does not
 apply to system level scanning.
 For more information, see:
 .br
-.B lvmconfig --withcomments devices/global_filter
+.B lvmconfig \-\-withcomments devices/global_filter
 .IP \[bu] 2
 If lvmetad is started or restarted after devices are visible, or
 if the global_filter has changed, then all devices must be rescanned
@@ -74,17 +74,17 @@ Auto-activation of VGs or LVs can be enabled/disabled using:
 
 For more information, see:
 .br
-.B lvmconfig --withcomments activation/auto_activation_volume_list
+.B lvmconfig \-\-withcomments activation/auto_activation_volume_list
 
 When this setting is undefined, all LVs are auto-activated (when lvm is
 fully integrated with the event-driven system services.)
 
 When a VG or LV is not auto-activated, traditional activation using
-vgchange or lvchange -a|--activate is needed.
+vgchange or lvchange -a|\-\-activate is needed.
 .IP \[bu] 2
 pvscan auto-activation can be only done in combination with \-\-cache.
 .IP \[bu] 2
-Auto-activation is designated by the "a" argument in '-a|--activate ay'.
+Auto-activation is designated by the "a" argument in '-a|\-\-activate ay'.
 This is meant to distinguish system generated commands from explicit user
 commands, although it can be used in any activation command.  Whenever it
 is used, the auto_activation_volume_list is applied.
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index d7c35dd..a13d1cd 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -50,7 +50,7 @@ read the named devices.
 LVM udev rules and systemd services are used to initiate automatic device
 scanning.
 .IP \[bu] 2
-To prevent devices from being scanned by pvscan --cache, add them
+To prevent devices from being scanned by pvscan \-\-cache, add them
 to
 .BR lvm.conf (5)
 .B devices/global_filter.
@@ -58,7 +58,7 @@ The devices/filter setting does not
 apply to system level scanning.
 For more information, see:
 .br
-.B lvmconfig --withcomments devices/global_filter
+.B lvmconfig \-\-withcomments devices/global_filter
 .IP \[bu] 2
 If lvmetad is started or restarted after devices are visible, or
 if the global_filter has changed, then all devices must be rescanned
@@ -86,17 +86,17 @@ Auto-activation of VGs or LVs can be enabled/disabled using:
 
 For more information, see:
 .br
-.B lvmconfig --withcomments activation/auto_activation_volume_list
+.B lvmconfig \-\-withcomments activation/auto_activation_volume_list
 
 When this setting is undefined, all LVs are auto-activated (when lvm is
 fully integrated with the event-driven system services.)
 
 When a VG or LV is not auto-activated, traditional activation using
-vgchange or lvchange -a|--activate is needed.
+vgchange or lvchange -a|\-\-activate is needed.
 .IP \[bu] 2
 pvscan auto-activation can be only done in combination with \-\-cache.
 .IP \[bu] 2
-Auto-activation is designated by the "a" argument in '-a|--activate ay'.
+Auto-activation is designated by the "a" argument in '-a|\-\-activate ay'.
 This is meant to distinguish system generated commands from explicit user
 commands, although it can be used in any activation command.  Whenever it
 is used, the auto_activation_volume_list is applied.
@@ -111,19 +111,19 @@ Display PV information.
 .br
 .RS 4
 .ad l
-[ \fB-e\fP|\fB--exported\fP ]
+[ \fB-e\fP|\fB\-\-exported\fP ]
 .ad b
 .br
 .ad l
-[ \fB-n\fP|\fB--novolumegroup\fP ]
+[ \fB-n\fP|\fB\-\-novolumegroup\fP ]
 .ad b
 .br
 .ad l
-[ \fB-s\fP|\fB--short\fP ]
+[ \fB-s\fP|\fB\-\-short\fP ]
 .ad b
 .br
 .ad l
-[ \fB-u\fP|\fB--uuid\fP ]
+[ \fB-u\fP|\fB\-\-uuid\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -133,23 +133,23 @@ Display PV information.
 Populate the lvmetad cache by scanning PVs.
 .br
 .P
-\fBpvscan\fP \fB--cache\fP
+\fBpvscan\fP \fB\-\-cache\fP
 .br
 .RS 4
 .ad l
-[ \fB-b\fP|\fB--background\fP ]
+[ \fB-b\fP|\fB\-\-background\fP ]
 .ad b
 .br
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+[ \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
 .ad b
 .br
 .ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+[ \fB-j\fP|\fB\-\-major\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--minor\fP \fINumber\fP ]
+[    \fB\-\-minor\fP \fINumber\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -163,11 +163,11 @@ Common options for command:
 .
 .RS 4
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -175,62 +175,62 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+\fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP
+\fB-b\fP|\fB\-\-background\fP
 .br
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
@@ -238,20 +238,20 @@ background.
 .ad b
 .HP
 .ad l
-\fB--cache\fP
+\fB\-\-cache\fP
 .br
 Scan one or more devices and send the metadata to lvmetad.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -260,78 +260,78 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-e\fP|\fB--exported\fP
+\fB-e\fP|\fB\-\-exported\fP
 .br
 Only show PVs belonging to exported VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-j\fP|\fB--major\fP \fINumber\fP
+\fB-j\fP|\fB\-\-major\fP \fINumber\fP
 .br
 The major number of a device.
 .ad b
 .HP
 .ad l
-\fB--minor\fP \fINumber\fP
+\fB\-\-minor\fP \fINumber\fP
 .br
 The minor number of a device.
 .ad b
 .HP
 .ad l
-\fB-n\fP|\fB--novolumegroup\fP
+\fB-n\fP|\fB\-\-novolumegroup\fP
 .br
 Only show PVs not belonging to any VG.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -342,13 +342,13 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-s\fP|\fB--short\fP
+\fB-s\fP|\fB\-\-short\fP
 .br
 Short listing format.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -358,26 +358,26 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-u\fP|\fB--uuid\fP
+\fB-u\fP|\fB\-\-uuid\fP
 .br
 Show UUIDs in addition to device names.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -409,7 +409,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index f4b6f38..837030d 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -31,27 +31,27 @@ It may also be useful to regularly back up the files in
 .br
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--file\fP \fIString\fP ]
+[ \fB-f\fP|\fB\-\-file\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[    \fB--foreign\fP ]
+[    \fB\-\-foreign\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -65,64 +65,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -131,21 +131,21 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--file\fP \fIString\fP
+\fB-f\fP|\fB\-\-file\fP \fIString\fP
 .br
 Write the backup to the named file.
 When backing up more than one VG, the file name is
@@ -153,33 +153,33 @@ treated as a template, and %s is replaced by the VG name.
 .ad b
 .HP
 .ad l
-\fB--foreign\fP
+\fB\-\-foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -188,21 +188,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -216,7 +216,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -227,7 +227,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -237,20 +237,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -276,7 +276,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 07cc1ed..72ff2e7 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -11,67 +11,67 @@ vgcfgrestore \- Restore volume group configuration
 .br
 .P
 .ad l
-    \fB--commandprofile\fP \fIString\fP
+    \fB\-\-commandprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--config\fP \fIString\fP
+    \fB\-\-config\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-d\fP|\fB--debug\fP
+ \fB-d\fP|\fB\-\-debug\fP
 .ad b
 .br
 .ad l
-    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-f\fP|\fB--file\fP \fIString\fP
+ \fB-f\fP|\fB\-\-file\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--force\fP
+    \fB\-\-force\fP
 .ad b
 .br
 .ad l
- \fB-h\fP|\fB--help\fP
+ \fB-h\fP|\fB\-\-help\fP
 .ad b
 .br
 .ad l
- \fB-l\fP|\fB--list\fP
+ \fB-l\fP|\fB\-\-list\fP
 .ad b
 .br
 .ad l
-    \fB--longhelp\fP
+    \fB\-\-longhelp\fP
 .ad b
 .br
 .ad l
- \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+ \fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .ad b
 .br
 .ad l
-    \fB--profile\fP \fIString\fP
+    \fB\-\-profile\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-q\fP|\fB--quiet\fP
+ \fB-q\fP|\fB\-\-quiet\fP
 .ad b
 .br
 .ad l
- \fB-t\fP|\fB--test\fP
+ \fB-t\fP|\fB\-\-test\fP
 .ad b
 .br
 .ad l
- \fB-v\fP|\fB--verbose\fP
+ \fB-v\fP|\fB\-\-verbose\fP
 .ad b
 .br
 .ad l
-    \fB--version\fP
+    \fB\-\-version\fP
 .ad b
 .br
 .ad l
- \fB-y\fP|\fB--yes\fP
+ \fB-y\fP|\fB\-\-yes\fP
 .ad b
 .SH DESCRIPTION
 vgcfgrestore restores the metadata of a VG from a text back up file
@@ -100,7 +100,7 @@ Restore VG metadata from last backup.
 Restore VG metadata from specified file.
 .br
 .P
-\fBvgcfgrestore\fP \fB-f\fP|\fB--file\fP \fIString\fP \fIVG\fP
+\fBvgcfgrestore\fP \fB-f\fP|\fB\-\-file\fP \fIString\fP \fIVG\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -111,7 +111,7 @@ Restore VG metadata from specified file.
 List all VG metadata backups.
 .br
 .P
-\fBvgcfgrestore\fP \fB-l\fP|\fB--list\fP \fIVG\fP
+\fBvgcfgrestore\fP \fB-l\fP|\fB\-\-list\fP \fIVG\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -122,7 +122,7 @@ List all VG metadata backups.
 List one VG metadata backup file.
 .br
 .P
-\fBvgcfgrestore\fP \fB-l\fP|\fB--list\fP \fB-f\fP|\fB--file\fP \fIString\fP
+\fBvgcfgrestore\fP \fB-l\fP|\fB\-\-list\fP \fB-f\fP|\fB\-\-file\fP \fIString\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -137,11 +137,11 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
-[    \fB--force\fP ]
+[    \fB\-\-force\fP ]
 .ad b
 .RE
 
@@ -149,64 +149,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -215,28 +215,28 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--file\fP \fIString\fP
+\fB-f\fP|\fB\-\-file\fP \fIString\fP
 .br
 Read metadata backup from the named file.
 Usually this file was created by vgcfgbackup.
 .ad b
 .HP
 .ad l
-\fB--force\fP ...
+\fB\-\-force\fP ...
 .br
 Force metadata restore even with thin pool LVs.
 Use with extreme caution. Most changes to thin metadata
@@ -246,26 +246,26 @@ thin pool kernel metadata precisely.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--list\fP
+\fB-l\fP|\fB\-\-list\fP
 .br
 List metadata backup and archive files pertaining to the VG.
-May be used with --file. Does not restore the VG.
+May be used with \-\-file. Does not restore the VG.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
@@ -274,21 +274,21 @@ can be used for accessing old data.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -298,20 +298,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -337,7 +337,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index cd5cc30..ce7da74 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -11,187 +11,187 @@ vgchange \- Change volume group attributes
 .br
 .P
 .ad l
- \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+ \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .ad b
 .br
 .ad l
-    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
+    \fB\-\-activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .ad b
 .br
 .ad l
-    \fB--addtag\fP \fITag\fP
+    \fB\-\-addtag\fP \fITag\fP
 .ad b
 .br
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
 .br
 .ad l
- \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
+ \fB-c\fP|\fB\-\-clustered\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--commandprofile\fP \fIString\fP
+    \fB\-\-commandprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--config\fP \fIString\fP
+    \fB\-\-config\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-d\fP|\fB--debug\fP
+ \fB-d\fP|\fB\-\-debug\fP
 .ad b
 .br
 .ad l
-    \fB--deltag\fP \fITag\fP
+    \fB\-\-deltag\fP \fITag\fP
 .ad b
 .br
 .ad l
-    \fB--detachprofile\fP
+    \fB\-\-detachprofile\fP
 .ad b
 .br
 .ad l
-    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-f\fP|\fB--force\fP
+ \fB-f\fP|\fB\-\-force\fP
 .ad b
 .br
 .ad l
- \fB-h\fP|\fB--help\fP
+ \fB-h\fP|\fB\-\-help\fP
 .ad b
 .br
 .ad l
- \fB-K\fP|\fB--ignoreactivationskip\fP
+ \fB-K\fP|\fB\-\-ignoreactivationskip\fP
 .ad b
 .br
 .ad l
-    \fB--ignorelockingfailure\fP
+    \fB\-\-ignorelockingfailure\fP
 .ad b
 .br
 .ad l
-    \fB--ignoremonitoring\fP
+    \fB\-\-ignoremonitoring\fP
 .ad b
 .br
 .ad l
-    \fB--ignoreskippedcluster\fP
+    \fB\-\-ignoreskippedcluster\fP
 .ad b
 .br
 .ad l
-    \fB--lockopt\fP \fIString\fP
+    \fB\-\-lockopt\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--lockstart\fP
+    \fB\-\-lockstart\fP
 .ad b
 .br
 .ad l
-    \fB--lockstop\fP
+    \fB\-\-lockstop\fP
 .ad b
 .br
 .ad l
-    \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
+    \fB\-\-locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .ad b
 .br
 .ad l
- \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
+ \fB-l\fP|\fB\-\-logicalvolume\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--longhelp\fP
+    \fB\-\-longhelp\fP
 .ad b
 .br
 .ad l
- \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
+ \fB-p\fP|\fB\-\-maxphysicalvolumes\fP \fINumber\fP
 .ad b
 .br
 .ad l
-    \fB--metadataprofile\fP \fIString\fP
+    \fB\-\-metadataprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--monitor\fP \fBy\fP|\fBn\fP
+    \fB\-\-monitor\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--noudevsync\fP
+    \fB\-\-noudevsync\fP
 .ad b
 .br
 .ad l
- \fB-P\fP|\fB--partial\fP
+ \fB-P\fP|\fB\-\-partial\fP
 .ad b
 .br
 .ad l
- \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
+ \fB-s\fP|\fB\-\-physicalextentsize\fP \fISize\fP[m|UNIT]
 .ad b
 .br
 .ad l
-    \fB--poll\fP \fBy\fP|\fBn\fP
+    \fB\-\-poll\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--profile\fP \fIString\fP
+    \fB\-\-profile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+    \fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .ad b
 .br
 .ad l
- \fB-q\fP|\fB--quiet\fP
+ \fB-q\fP|\fB\-\-quiet\fP
 .ad b
 .br
 .ad l
-    \fB--refresh\fP
+    \fB\-\-refresh\fP
 .ad b
 .br
 .ad l
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .ad b
 .br
 .ad l
- \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
+ \fB-x\fP|\fB\-\-resizeable\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-S\fP|\fB--select\fP \fIString\fP
+ \fB-S\fP|\fB\-\-select\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--sysinit\fP
+    \fB\-\-sysinit\fP
 .ad b
 .br
 .ad l
-    \fB--systemid\fP \fIString\fP
+    \fB\-\-systemid\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-t\fP|\fB--test\fP
+ \fB-t\fP|\fB\-\-test\fP
 .ad b
 .br
 .ad l
- \fB-u\fP|\fB--uuid\fP
+ \fB-u\fP|\fB\-\-uuid\fP
 .ad b
 .br
 .ad l
- \fB-v\fP|\fB--verbose\fP
+ \fB-v\fP|\fB\-\-verbose\fP
 .ad b
 .br
 .ad l
-    \fB--version\fP
+    \fB\-\-version\fP
 .ad b
 .br
 .ad l
-    \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
+    \fB\-\-[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .ad b
 .br
 .ad l
- \fB-y\fP|\fB--yes\fP
+ \fB-y\fP|\fB\-\-yes\fP
 .ad b
 .SH DESCRIPTION
 vgchange changes VG attributes, changes LV activation in the kernel, and
@@ -206,67 +206,67 @@ required, after which the others are optional.
 .P
 \fBvgchange\fP
 .RS 4
-( \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP,
+( \fB-l\fP|\fB\-\-logicalvolume\fP \fINumber\fP,
 .ad b
 .br
 .ad l
-  \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP,
+  \fB-p\fP|\fB\-\-maxphysicalvolumes\fP \fINumber\fP,
 .ad b
 .br
 .ad l
-  \fB-u\fP|\fB--uuid\fP,
+  \fB-u\fP|\fB\-\-uuid\fP,
 .ad b
 .br
 .ad l
-  \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP,
+  \fB-c\fP|\fB\-\-clustered\fP \fBy\fP|\fBn\fP,
 .ad b
 .br
 .ad l
-  \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT],
+  \fB-s\fP|\fB\-\-physicalextentsize\fP \fISize\fP[m|UNIT],
 .ad b
 .br
 .ad l
-  \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP,
+  \fB-x\fP|\fB\-\-resizeable\fP \fBy\fP|\fBn\fP,
 .ad b
 .br
 .ad l
-     \fB--addtag\fP \fITag\fP,
+     \fB\-\-addtag\fP \fITag\fP,
 .ad b
 .br
 .ad l
-     \fB--deltag\fP \fITag\fP,
+     \fB\-\-deltag\fP \fITag\fP,
 .ad b
 .br
 .ad l
-     \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP,
+     \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP,
 .ad b
 .br
 .ad l
-     \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP,
+     \fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP,
 .ad b
 .br
 .ad l
-     \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP,
+     \fB\-\-[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP,
 .ad b
 .br
 .ad l
-     \fB--systemid\fP \fIString\fP,
+     \fB\-\-systemid\fP \fIString\fP,
 .ad b
 .br
 .ad l
-     \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP,
+     \fB\-\-locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP,
 .ad b
 .br
 .ad l
-     \fB--profile\fP \fIString\fP,
+     \fB\-\-profile\fP \fIString\fP,
 .ad b
 .br
 .ad l
-     \fB--detachprofile\fP,
+     \fB\-\-detachprofile\fP,
 .ad b
 .br
 .ad l
-     \fB--metadataprofile\fP \fIString\fP )
+     \fB\-\-metadataprofile\fP \fIString\fP )
 .RE
 .br
 .RS 4
@@ -281,19 +281,19 @@ required, after which the others are optional.
 Start or stop monitoring LVs from dmeventd.
 .br
 .P
-\fBvgchange\fP \fB--monitor\fP \fBy\fP|\fBn\fP
+\fBvgchange\fP \fB\-\-monitor\fP \fBy\fP|\fBn\fP
 .br
 .RS 4
 .ad l
-[    \fB--sysinit\fP ]
+[    \fB\-\-sysinit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -307,11 +307,11 @@ Start or stop monitoring LVs from dmeventd.
 Start or stop processing LV conversions.
 .br
 .P
-\fBvgchange\fP \fB--poll\fP \fBy\fP|\fBn\fP
+\fBvgchange\fP \fB\-\-poll\fP \fBy\fP|\fBn\fP
 .br
 .RS 4
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -325,35 +325,35 @@ Start or stop processing LV conversions.
 Activate or deactivate LVs.
 .br
 .P
-\fBvgchange\fP \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+\fBvgchange\fP \fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
 .RS 4
 .ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+[ \fB-K\fP|\fB\-\-ignoreactivationskip\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[    \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
+[    \fB\-\-activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP ]
 .ad b
 .br
 .ad l
-[    \fB--sysinit\fP ]
+[    \fB\-\-sysinit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-monitor\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -367,23 +367,23 @@ Activate or deactivate LVs.
 Reactivate LVs using the latest metadata.
 .br
 .P
-\fBvgchange\fP \fB--refresh\fP
+\fBvgchange\fP \fB\-\-refresh\fP
 .br
 .RS 4
 .ad l
-[    \fB--sysinit\fP ]
+[    \fB\-\-sysinit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-monitor\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poll\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-poll\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -397,11 +397,11 @@ Reactivate LVs using the latest metadata.
 Start the lockspace of a shared VG in lvmlockd.
 .br
 .P
-\fBvgchange\fP \fB--lockstart\fP
+\fBvgchange\fP \fB\-\-lockstart\fP
 .br
 .RS 4
 .ad l
-[    \fB--lockopt\fP \fIString\fP ]
+[    \fB\-\-lockopt\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -415,11 +415,11 @@ Start the lockspace of a shared VG in lvmlockd.
 Stop the lockspace of a shared VG in lvmlockd.
 .br
 .P
-\fBvgchange\fP \fB--lockstop\fP
+\fBvgchange\fP \fB\-\-lockstop\fP
 .br
 .RS 4
 .ad l
-[    \fB--lockopt\fP \fIString\fP ]
+[    \fB\-\-lockopt\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -434,31 +434,31 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoremonitoring\fP ]
+[    \fB\-\-ignoremonitoring\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -466,57 +466,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+\fB-a\fP|\fB\-\-activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
 Change the active state of LVs.
 An active LV can be used through a block device,
@@ -541,7 +541,7 @@ See clvmd(8) for more information about activation options \fBey\fP, \fBsy\fP, \
 .ad b
 .HP
 .ad l
-\fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
+\fB\-\-activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .br
 Determines if LV activation is allowed when PVs are missing,
 e.g. because of a device failure.
@@ -556,14 +556,14 @@ See \fBlvmraid\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--addtag\fP \fITag\fP
+\fB\-\-addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -584,28 +584,28 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
+\fB-c\fP|\fB\-\-clustered\fP \fBy\fP|\fBn\fP
 .br
 Change the clustered property of a VG using clvmd.
 See clvmd(8) for more information about clustered VGs.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -614,83 +614,83 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--deltag\fP \fITag\fP
+\fB\-\-deltag\fP \fITag\fP
 .br
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
 .HP
 .ad l
-\fB--detachprofile\fP
+\fB\-\-detachprofile\fP
 .br
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-K\fP|\fB--ignoreactivationskip\fP
+\fB-K\fP|\fB\-\-ignoreactivationskip\fP
 .br
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoremonitoring\fP
+\fB\-\-ignoremonitoring\fP
 .br
-Do not interact with dmeventd unless --monitor is specified.
+Do not interact with dmeventd unless \-\-monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--lockopt\fP \fIString\fP
+\fB\-\-lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
 See lvmlockd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--lockstart\fP
+\fB\-\-lockstart\fP
 .br
 Start the lockspace of a shared VG in lvmlockd.
 lvmlockd locks becomes available for the VG, allowing LVM to use the VG.
@@ -698,7 +698,7 @@ See lvmlockd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--lockstop\fP
+\fB\-\-lockstop\fP
 .br
 Stop the lockspace of a shared VG in lvmlockd.
 lvmlockd locks become unavailable for the VG, preventing LVM from using the VG.
@@ -706,42 +706,42 @@ See lvmlockd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
+\fB\-\-locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
 Change the VG lock type to or from a shared lock type used with lvmlockd.
 See lvmlockd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
+\fB-l\fP|\fB\-\-logicalvolume\fP \fINumber\fP
 .br
 Sets the maximum number of LVs allowed in a VG.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
+\fB-p\fP|\fB\-\-maxphysicalvolumes\fP \fINumber\fP
 .br
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
-For large numbers of PVs, also see options --pvmetadatacopies,
-and --vgmetadatacopies for improving performance.
+For large numbers of PVs, also see options \-\-pvmetadatacopies,
+and \-\-vgmetadatacopies for improving performance.
 .ad b
 .HP
 .ad l
-\fB--metadataprofile\fP \fIString\fP
+\fB\-\-metadataprofile\fP \fIString\fP
 .br
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--monitor\fP \fBy\fP|\fBn\fP
+\fB\-\-monitor\fP \fBy\fP|\fBn\fP
 .br
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
@@ -750,7 +750,7 @@ See dmeventd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -759,7 +759,7 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -768,7 +768,7 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
+\fB-s\fP|\fB\-\-physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
 Sets the physical extent size of PVs in the VG.
 The value must be either a power of 2 of at least 1 sector
@@ -782,26 +782,26 @@ contiguous range of extents used in a LV must start and end on an extent boundar
 .ad b
 .HP
 .ad l
-\fB--poll\fP \fBy\fP|\fBn\fP
+\fB\-\-poll\fP \fBy\fP|\fBn\fP
 .br
 When yes, start the background transformation of an LV.
 An incomplete transformation, e.g. pvmove or lvconvert interrupted
-by reboot or crash, can be restarted from the last checkpoint with --poll y.
+by reboot or crash, can be restarted from the last checkpoint with \-\-poll y.
 When no, background transformation of an LV will not occur, and the
 transformation will not complete. It may not be appropriate to immediately
-poll an LV after activation, in which case --poll n can be used to defer
-polling until a later --poll y command.
+poll an LV after activation, in which case \-\-poll n can be used to defer
+polling until a later \-\-poll y command.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+\fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
@@ -814,14 +814,14 @@ on the ability to use vgsplit later.)
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--refresh\fP
+\fB\-\-refresh\fP
 .br
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
@@ -830,7 +830,7 @@ sharing is being used.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -841,19 +841,19 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
+\fB-x\fP|\fB\-\-resizeable\fP \fBy\fP|\fBn\fP
 .br
 Enables or disables the addition or removal of PVs to/from a VG
 (by vgextend/vgreduce).
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -861,20 +861,20 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB--sysinit\fP
+\fB\-\-sysinit\fP
 .br
 Indicates that vgchange/lvchange is being invoked from early system initialisation
 scripts (e.g. rc.sysinit or an initrd), before writable filesystems are
 available. As such, some functionality needs to be disabled and this option
 acts as a shortcut which selects an appropriate set of options. Currently,
-this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
---poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
+this is equivalent to using \-\-ignorelockingfailure, \-\-ignoremonitoring,
+\-\-poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
 When used in conjunction with lvmetad enabled and running,
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
 .ad b
 .HP
 .ad l
-\fB--systemid\fP \fIString\fP
+\fB\-\-systemid\fP \fIString\fP
 .br
 Changes the system ID of the VG.  Using this option requires caution
 because the VG may become foreign to the host running the command,
@@ -883,7 +883,7 @@ See lvmsystemid(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -893,26 +893,26 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-u\fP|\fB--uuid\fP
+\fB-u\fP|\fB\-\-uuid\fP
 .br
 Generate new random UUID for specified VGs.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
+\fB\-\-[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
@@ -930,7 +930,7 @@ all PVs, and then to become unmanaged.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -950,7 +950,7 @@ in place of a VG, LV or PV.
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
-be omitted if the \fB--select\fP option is used.
+be omitted if the \fB\-\-select\fP option is used.
 No arg appears in this position.
 .HP
 \fIString\fP
@@ -967,7 +967,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 9612367..d172f18 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -16,7 +16,7 @@ vgck checks LVM metadata for consistency.
 .br
 .RS 4
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -30,64 +30,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -96,47 +96,47 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -147,7 +147,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -157,20 +157,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -201,7 +201,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index b322b8f..9c07bce 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -19,31 +19,31 @@ longer needed in general.
 .br
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
-[    \fB--labelsector\fP \fINumber\fP ]
+[    \fB\-\-labelsector\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--bootloaderareasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-bootloaderareasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-metadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -54,78 +54,78 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
+\fB\-\-bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
 Create a separate bootloader area of specified size besides PV's data
 area. The bootloader area is an area of reserved space on the PV from
 which LVM will not allocate any extents and it's kept untouched. This is
 primarily aimed for use with bootloaders to embed their own data or metadata.
-The start of the bootloader area is always aligned, see also --dataalignment
-and --dataalignmentoffset. The bootloader area size may eventually
+The start of the bootloader area is always aligned, see also \-\-dataalignment
+and \-\-dataalignmentoffset. The bootloader area size may eventually
 end up increased due to the alignment, but it's never less than the
 size that is requested. To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -134,34 +134,34 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--labelsector\fP \fINumber\fP
+\fB\-\-labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
@@ -170,20 +170,20 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--metadatasize\fP \fISize\fP[m|UNIT]
+\fB\-\-metadatasize\fP \fISize\fP[m|UNIT]
 .br
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
@@ -192,14 +192,14 @@ can be used for accessing old data.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+\fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
@@ -212,14 +212,14 @@ on the ability to use vgsplit later.)
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -230,7 +230,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -240,20 +240,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -279,7 +279,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 6bd4b02..871c6aa 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -17,91 +17,91 @@ devices are also available with vgcreate.
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP ]
+[ \fB-c\fP|\fB\-\-clustered\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP ]
+[ \fB-l\fP|\fB\-\-maxlogicalvolumes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP ]
+[ \fB-p\fP|\fB\-\-maxphysicalvolumes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
-[ \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT] ]
+[ \fB-s\fP|\fB\-\-physicalextentsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--addtag\fP \fITag\fP ]
+[    \fB\-\-addtag\fP \fITag\fP ]
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
+[    \fB\-\-metadataprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--labelsector\fP \fINumber\fP ]
+[    \fB\-\-labelsector\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-metadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
-[    \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
+[    \fB\-\-[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--dataalignment\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-dataalignment\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--shared\fP ]
+[    \fB\-\-shared\fP ]
 .ad b
 .br
 .ad l
-[    \fB--systemid\fP \fIString\fP ]
+[    \fB\-\-systemid\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP ]
+[    \fB\-\-locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP ]
 .ad b
 .br
 .ad l
-[    \fB--lockopt\fP \fIString\fP ]
+[    \fB\-\-lockopt\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -112,64 +112,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--addtag\fP \fITag\fP
+\fB\-\-addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -190,14 +190,14 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
+\fB-c\fP|\fB\-\-clustered\fP \fBy\fP|\fBn\fP
 .br
 Create a clustered VG using clvmd if LVM is compiled with cluster support.
 This allows multiple hosts to share a VG on shared devices.
@@ -207,14 +207,14 @@ See clvmd(8) for more information about clustered VGs.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -223,50 +223,50 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--dataalignment\fP \fISize\fP[k|UNIT]
+\fB\-\-dataalignment\fP \fISize\fP[k|UNIT]
 .br
 Align the start of the data to a multiple of this number.
 Also specify an appropriate Physical Extent size when creating a VG.
 To see the location of the first Physical Extent of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
-See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
+See lvm.conf/data_alignment_offset_detection and \-\-dataalignmentoffset.
 .ad b
 .HP
 .ad l
-\fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
+\fB\-\-dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 Shift the start of the data area by this additional offset.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--labelsector\fP \fINumber\fP
+\fB\-\-labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
@@ -275,56 +275,56 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
-\fB--lockopt\fP \fIString\fP
+\fB\-\-lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
 See lvmlockd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
+\fB\-\-locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
-Specify the VG lock type directly in place of using --shared.
+Specify the VG lock type directly in place of using \-\-shared.
 See lvmlockd(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
+\fB-l\fP|\fB\-\-maxlogicalvolumes\fP \fINumber\fP
 .br
 Sets the maximum number of LVs allowed in a VG.
 .ad b
 .HP
 .ad l
-\fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
+\fB-p\fP|\fB\-\-maxphysicalvolumes\fP \fINumber\fP
 .br
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
-For large numbers of PVs, also see options --pvmetadatacopies,
-and --vgmetadatacopies for improving performance.
+For large numbers of PVs, also see options \-\-pvmetadatacopies,
+and \-\-vgmetadatacopies for improving performance.
 .ad b
 .HP
 .ad l
-\fB--metadataprofile\fP \fIString\fP
+\fB\-\-metadataprofile\fP \fIString\fP
 .br
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--metadatasize\fP \fISize\fP[m|UNIT]
+\fB\-\-metadatasize\fP \fISize\fP[m|UNIT]
 .br
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
@@ -333,7 +333,7 @@ can be used for accessing old data.
 .ad b
 .HP
 .ad l
-\fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
+\fB-s\fP|\fB\-\-physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
 Sets the physical extent size of PVs in the VG.
 The value must be either a power of 2 of at least 1 sector
@@ -344,14 +344,14 @@ without recreating the VG, unless no extents need moving.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+\fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
@@ -364,14 +364,14 @@ on the ability to use vgsplit later.)
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -382,7 +382,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--shared\fP
+\fB\-\-shared\fP
 .br
 Create a shared VG using lvmlockd if LVM is compiled with lockd support.
 lvmlockd will select lock type sanlock or dlm depending on which lock
@@ -393,7 +393,7 @@ See lvmlockd(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
-\fB--systemid\fP \fIString\fP
+\fB\-\-systemid\fP \fIString\fP
 .br
 Specifies the system ID that will be given to the new VG, overriding the
 system ID of the host running the command. A VG is normally created
@@ -405,7 +405,7 @@ See lvmsystemid(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -415,20 +415,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
+\fB\-\-[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
@@ -446,7 +446,7 @@ all PVs, and then to become unmanaged.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -454,11 +454,11 @@ answer yes. Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+\fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .br
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
---restorefile or --uuid are specified.
+\-\-restorefile or \-\-uuid are specified.
 .ad b
 .SH VARIABLES
 .HP
@@ -490,7 +490,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 6fe90a5..196aee4 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -19,95 +19,95 @@ and more, using a more compact and configurable output format.
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--activevolumegroups\fP ]
+[ \fB-A\fP|\fB\-\-activevolumegroups\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--colon\fP ]
+[ \fB-c\fP|\fB\-\-colon\fP ]
 .ad b
 .br
 .ad l
-[ \fB-C\fP|\fB--columns\fP ]
+[ \fB-C\fP|\fB\-\-columns\fP ]
 .ad b
 .br
 .ad l
-[ \fB-o\fP|\fB--options\fP \fIString\fP ]
+[ \fB-o\fP|\fB\-\-options\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-s\fP|\fB--short\fP ]
+[ \fB-s\fP|\fB\-\-short\fP ]
 .ad b
 .br
 .ad l
-[ \fB-O\fP|\fB--sort\fP \fIString\fP ]
+[ \fB-O\fP|\fB\-\-sort\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--aligned\fP ]
+[    \fB\-\-aligned\fP ]
 .ad b
 .br
 .ad l
-[    \fB--binary\fP ]
+[    \fB\-\-binary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
+[    \fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
 .ad b
 .br
 .ad l
-[    \fB--foreign\fP ]
+[    \fB\-\-foreign\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--logonly\fP ]
+[    \fB\-\-logonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noheadings\fP ]
+[    \fB\-\-noheadings\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosuffix\fP ]
+[    \fB\-\-nosuffix\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--shared\fP ]
+[    \fB\-\-shared\fP ]
 .ad b
 .br
 .ad l
-[    \fB--separator\fP \fIString\fP ]
+[    \fB\-\-separator\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unbuffered\fP ]
+[    \fB\-\-unbuffered\fP ]
 .ad b
 .br
 .ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
+[    \fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -121,70 +121,70 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-A\fP|\fB--activevolumegroups\fP
+\fB-A\fP|\fB\-\-activevolumegroups\fP
 .br
 Only select active VGs. The VG is considered active
 if at least one of its LVs is active.
 .ad b
 .HP
 .ad l
-\fB--aligned\fP
+\fB\-\-aligned\fP
 .br
-Use with --separator to align the output columns
+Use with \-\-separator to align the output columns
 .ad b
 .HP
 .ad l
-\fB--binary\fP
+\fB\-\-binary\fP
 .br
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
@@ -192,28 +192,28 @@ the "unknown" value which denotes that the value could not be determined).
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--colon\fP
+\fB-c\fP|\fB\-\-colon\fP
 .br
 Generate colon separated output for easier parsing in scripts or programs.
 Also see vgs(8) which provides considerably more control over the output.
 .ad b
 .HP
 .ad l
-\fB-C\fP|\fB--columns\fP
+\fB-C\fP|\fB\-\-columns\fP
 .br
 Display output in columns, the equivalent of vgs(8).
 Options listed are the same as options given in vgs(8).
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -222,80 +222,80 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
+\fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--foreign\fP
+\fB\-\-foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--logonly\fP
+\fB\-\-logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--noheadings\fP
+\fB\-\-noheadings\fP
 .br
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--nosuffix\fP
+\fB\-\-nosuffix\fP
 .br
-Suppress the suffix on output sizes. Use with --units
+Suppress the suffix on output sizes. Use with \-\-units
 (except h and H) if processing the output.
 .ad b
 .HP
 .ad l
-\fB-o\fP|\fB--options\fP \fIString\fP
+\fB-o\fP|\fB\-\-options\fP \fIString\fP
 .br
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
@@ -317,7 +317,7 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -326,21 +326,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -354,7 +354,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -365,12 +365,12 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -378,13 +378,13 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB--separator\fP \fIString\fP
+\fB\-\-separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--shared\fP
+\fB\-\-shared\fP
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
@@ -392,20 +392,20 @@ See lvmlockd(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
-\fB-s\fP|\fB--short\fP
+\fB-s\fP|\fB\-\-short\fP
 .br
 Give a short listing showing the existence of VGs.
 .ad b
 .HP
 .ad l
-\fB-O\fP|\fB--sort\fP \fIString\fP
+\fB-O\fP|\fB\-\-sort\fP \fIString\fP
 .br
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -415,37 +415,37 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--unbuffered\fP
+\fB\-\-unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
+\fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
-Custom units can be specified, e.g. --units 3M.
+Custom units can be specified, e.g. \-\-units 3M.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -476,7 +476,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index b714404..9797bb4 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -24,7 +24,7 @@ Export specified VGs.
 .br
 .RS 4
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -34,7 +34,7 @@ Export specified VGs.
 Export all VGs.
 .br
 .P
-\fBvgexport\fP \fB-a\fP|\fB--all\fP
+\fBvgexport\fP \fB-a\fP|\fB\-\-all\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -45,7 +45,7 @@ Common options for command:
 .
 .RS 4
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -53,69 +53,69 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -124,47 +124,47 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -175,12 +175,12 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -188,7 +188,7 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -198,20 +198,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -231,7 +231,7 @@ in place of a VG, LV or PV.
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
-be omitted if the \fB--select\fP option is used.
+be omitted if the \fB\-\-select\fP option is used.
 No arg appears in this position.
 .HP
 \fIString\fP
@@ -248,7 +248,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 5b65c99..9150918 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -24,51 +24,51 @@ will initialize them. In this case pvcreate options can be used, e.g.
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[ \fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
-[    \fB--labelsector\fP \fINumber\fP ]
+[    \fB\-\-labelsector\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
+[    \fB\-\-metadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
+[    \fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
-[    \fB--metadataignore\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-metadataignore\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--dataalignment\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-dataalignment\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
+[    \fB\-\-dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--restoremissing\fP ]
+[    \fB\-\-restoremissing\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -79,71 +79,71 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -152,50 +152,50 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--dataalignment\fP \fISize\fP[k|UNIT]
+\fB\-\-dataalignment\fP \fISize\fP[k|UNIT]
 .br
 Align the start of the data to a multiple of this number.
 Also specify an appropriate Physical Extent size when creating a VG.
 To see the location of the first Physical Extent of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
-See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
+See lvm.conf/data_alignment_offset_detection and \-\-dataalignmentoffset.
 .ad b
 .HP
 .ad l
-\fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
+\fB\-\-dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 Shift the start of the data area by this additional offset.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--labelsector\fP \fINumber\fP
+\fB\-\-labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
@@ -204,13 +204,13 @@ in the source). Use with care.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--metadataignore\fP \fBy\fP|\fBn\fP
+\fB\-\-metadataignore\fP \fBy\fP|\fBn\fP
 .br
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
@@ -219,14 +219,14 @@ If no, lvm will store metadata on the PV.
 .ad b
 .HP
 .ad l
-\fB--metadatasize\fP \fISize\fP[m|UNIT]
+\fB\-\-metadatasize\fP \fISize\fP[m|UNIT]
 .br
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
@@ -235,14 +235,14 @@ can be used for accessing old data.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+\fB\-\-pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored@the front of the PV
@@ -255,14 +255,14 @@ on the ability to use vgsplit later.)
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -273,14 +273,14 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--restoremissing\fP
+\fB\-\-restoremissing\fP
 .br
 Add a PV back into a VG after the PV was missing and then returned,
 e.g. due to a transient failure. The PV is not reinitialized.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -290,20 +290,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -311,11 +311,11 @@ answer yes. Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
+\fB-Z\fP|\fB\-\-zero\fP \fBy\fP|\fBn\fP
 .br
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
---restorefile or --uuid are specified.
+\-\-restorefile or \-\-uuid are specified.
 .ad b
 .SH VARIABLES
 .HP
@@ -347,7 +347,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 84359e5..67635f3 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -21,7 +21,7 @@ Import specified VGs.
 .br
 .RS 4
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -31,7 +31,7 @@ Import specified VGs.
 Import all VGs.
 .br
 .P
-\fBvgimport\fP \fB-a\fP|\fB--all\fP
+\fBvgimport\fP \fB-a\fP|\fB\-\-all\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -42,11 +42,11 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -54,69 +54,69 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -125,54 +125,54 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -183,12 +183,12 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -196,7 +196,7 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -206,20 +206,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -239,7 +239,7 @@ in place of a VG, LV or PV.
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
-be omitted if the \fB--select\fP option is used.
+be omitted if the \fB\-\-select\fP option is used.
 No arg appears in this position.
 .HP
 \fIString\fP
@@ -256,7 +256,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 24afbf6..deefcde 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -19,11 +19,11 @@ changes the associated VG and PV UUIDs.
 .br
 .RS 4
 .ad l
-[ \fB-n\fP|\fB--basevgname\fP \fIVG\fP ]
+[ \fB-n\fP|\fB\-\-basevgname\fP \fIVG\fP ]
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--import\fP ]
+[ \fB-i\fP|\fB\-\-import\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -34,57 +34,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-n\fP|\fB--basevgname\fP \fIString\fP
+\fB-n\fP|\fB\-\-basevgname\fP \fIString\fP
 .br
 By default the snapshot VG will be renamed to the original name plus a
 numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
@@ -94,14 +94,14 @@ a numeric suffix will be added (like the previous example) to make it unique.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -110,54 +110,54 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-i\fP|\fB--import\fP
+\fB-i\fP|\fB\-\-import\fP
 .br
 Import exported VGs. Otherwise VGs that have been exported
 will not be changed (nor will their associated PVs).
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -167,20 +167,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -212,7 +212,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index 23c4285..367d479 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -16,11 +16,11 @@ of both VGs fit into the destination VG's limits.
 .br
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-l\fP|\fB--list\fP ]
+[ \fB-l\fP|\fB\-\-list\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -31,71 +31,71 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -104,53 +104,53 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--list\fP
+\fB-l\fP|\fB\-\-list\fP
 .br
 Display merged destination VG like vgdisplay -v.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -160,20 +160,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -199,7 +199,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 6cb68f3..511b80e 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -20,15 +20,15 @@ interoperating correctly.
 .br
 .RS 4
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--refresh\fP ]
+[    \fB\-\-refresh\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -42,64 +42,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -108,54 +108,54 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--refresh\fP
+\fB\-\-refresh\fP
 .br
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
@@ -164,7 +164,7 @@ sharing is being used.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -175,7 +175,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -185,20 +185,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -234,7 +234,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index bf4e354..f11b39f 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -9,75 +9,75 @@ vgreduce \- Remove physical volume(s) from a volume group
 .br
 .P
 .ad l
- \fB-a\fP|\fB--all\fP
+ \fB-a\fP|\fB\-\-all\fP
 .ad b
 .br
 .ad l
- \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
-    \fB--commandprofile\fP \fIString\fP
+    \fB\-\-commandprofile\fP \fIString\fP
 .ad b
 .br
 .ad l
-    \fB--config\fP \fIString\fP
+    \fB\-\-config\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-d\fP|\fB--debug\fP
+ \fB-d\fP|\fB\-\-debug\fP
 .ad b
 .br
 .ad l
-    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
 .br
 .ad l
- \fB-f\fP|\fB--force\fP
+ \fB-f\fP|\fB\-\-force\fP
 .ad b
 .br
 .ad l
- \fB-h\fP|\fB--help\fP
+ \fB-h\fP|\fB\-\-help\fP
 .ad b
 .br
 .ad l
-    \fB--longhelp\fP
+    \fB\-\-longhelp\fP
 .ad b
 .br
 .ad l
-    \fB--mirrorsonly\fP
+    \fB\-\-mirrorsonly\fP
 .ad b
 .br
 .ad l
-    \fB--profile\fP \fIString\fP
+    \fB\-\-profile\fP \fIString\fP
 .ad b
 .br
 .ad l
- \fB-q\fP|\fB--quiet\fP
+ \fB-q\fP|\fB\-\-quiet\fP
 .ad b
 .br
 .ad l
-    \fB--removemissing\fP
+    \fB\-\-removemissing\fP
 .ad b
 .br
 .ad l
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .ad b
 .br
 .ad l
- \fB-t\fP|\fB--test\fP
+ \fB-t\fP|\fB\-\-test\fP
 .ad b
 .br
 .ad l
- \fB-v\fP|\fB--verbose\fP
+ \fB-v\fP|\fB\-\-verbose\fP
 .ad b
 .br
 .ad l
-    \fB--version\fP
+    \fB\-\-version\fP
 .ad b
 .br
 .ad l
- \fB-y\fP|\fB--yes\fP
+ \fB-y\fP|\fB\-\-yes\fP
 .ad b
 .SH DESCRIPTION
 vgreduce removes one or more unused PVs from a VG.
@@ -96,7 +96,7 @@ Remove a PV from a VG.
 Remove all unused PVs from a VG.
 .br
 .P
-\fBvgreduce\fP \fB-a\fP|\fB--all\fP \fIVG\fP
+\fBvgreduce\fP \fB-a\fP|\fB\-\-all\fP \fIVG\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -107,11 +107,11 @@ Remove all unused PVs from a VG.
 Remove all missing PVs from a VG.
 .br
 .P
-\fBvgreduce\fP \fB--removemissing\fP \fIVG\fP
+\fBvgreduce\fP \fB\-\-removemissing\fP \fIVG\fP
 .br
 .RS 4
 .ad l
-[    \fB--mirrorsonly\fP ]
+[    \fB\-\-mirrorsonly\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -123,15 +123,15 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -139,77 +139,77 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 Removes all empty PVs if none are named on the command line.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -218,66 +218,66 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--mirrorsonly\fP
+\fB\-\-mirrorsonly\fP
 .br
 Only remove missing PVs from mirror LVs.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--removemissing\fP
+\fB\-\-removemissing\fP
 .br
 Removes all missing PVs from the VG, if there are no LVs allocated
 on them. This resumes normal operation of the VG (new LVs may again
 be created, changed and so on).
 If this is not possible because LVs are referencing the missing PVs,
-this option can be combined with --force to have the command remove
+this option can be combined with \-\-force to have the command remove
 any partial LVs. In this case, any LVs and dependent snapshots that
 were partly on the missing disks are removed completely, including
 those parts on disks that are still present.
@@ -286,7 +286,7 @@ some data first may be possible by activating LVs in partial mode.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -297,7 +297,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -307,20 +307,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -356,7 +356,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index c175188..b655545 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -22,19 +22,19 @@ without confirmation.
 .br
 .RS 4
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noudevsync\fP ]
+[    \fB\-\-noudevsync\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -45,64 +45,64 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -111,40 +111,40 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--noudevsync\fP
+\fB\-\-noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
@@ -153,21 +153,21 @@ ignore the devices LVM creates.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -178,12 +178,12 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -191,7 +191,7 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -201,20 +201,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -234,7 +234,7 @@ in place of a VG, LV or PV.
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
-be omitted if the \fB--select\fP option is used.
+be omitted if the \fB\-\-select\fP option is used.
 No arg appears in this position.
 .HP
 \fIString\fP
@@ -251,7 +251,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 4e8d609..9668500 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -42,15 +42,15 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-f\fP|\fB--force\fP ]
+[ \fB-f\fP|\fB\-\-force\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
 
@@ -58,71 +58,71 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -131,54 +131,54 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-f\fP|\fB--force\fP ...
+\fB-f\fP|\fB\-\-force\fP ...
 .br
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -189,7 +189,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -199,20 +199,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -238,7 +238,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 4313624..438a24a 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -16,103 +16,103 @@ vgs produces formatted output about VGs.
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--all\fP ]
+[ \fB-a\fP|\fB\-\-all\fP ]
 .ad b
 .br
 .ad l
-[ \fB-o\fP|\fB--options\fP \fIString\fP ]
+[ \fB-o\fP|\fB\-\-options\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[ \fB-S\fP|\fB--select\fP \fIString\fP ]
+[ \fB-S\fP|\fB\-\-select\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-O\fP|\fB--sort\fP \fIString\fP ]
+[ \fB-O\fP|\fB\-\-sort\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--aligned\fP ]
+[    \fB\-\-aligned\fP ]
 .ad b
 .br
 .ad l
-[    \fB--binary\fP ]
+[    \fB\-\-binary\fP ]
 .ad b
 .br
 .ad l
-[    \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
+[    \fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP ]
 .ad b
 .br
 .ad l
-[    \fB--foreign\fP ]
+[    \fB\-\-foreign\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
+[    \fB\-\-ignoreskippedcluster\fP ]
 .ad b
 .br
 .ad l
-[    \fB--logonly\fP ]
+[    \fB\-\-logonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nameprefixes\fP ]
+[    \fB\-\-nameprefixes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--noheadings\fP ]
+[    \fB\-\-noheadings\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nolocking\fP ]
+[    \fB\-\-nolocking\fP ]
 .ad b
 .br
 .ad l
-[    \fB--nosuffix\fP ]
+[    \fB\-\-nosuffix\fP ]
 .ad b
 .br
 .ad l
-[    \fB--readonly\fP ]
+[    \fB\-\-readonly\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 .ad l
-[    \fB--rows\fP ]
+[    \fB\-\-rows\fP ]
 .ad b
 .br
 .ad l
-[    \fB--separator\fP \fIString\fP ]
+[    \fB\-\-separator\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--shared\fP ]
+[    \fB\-\-shared\fP ]
 .ad b
 .br
 .ad l
-[    \fB--trustcache\fP ]
+[    \fB\-\-trustcache\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unbuffered\fP ]
+[    \fB\-\-unbuffered\fP ]
 .ad b
 .br
 .ad l
-[    \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
+[    \fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP ]
 .ad b
 .br
 .ad l
-[    \fB--unquoted\fP ]
+[    \fB\-\-unquoted\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -126,69 +126,69 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--aligned\fP
+\fB\-\-aligned\fP
 .br
-Use with --separator to align the output columns
+Use with \-\-separator to align the output columns
 .ad b
 .HP
 .ad l
-\fB-a\fP|\fB--all\fP
+\fB-a\fP|\fB\-\-all\fP
 .br
 List all VGs. Equivalent to not specifying any VGs.
 .ad b
 .HP
 .ad l
-\fB--binary\fP
+\fB\-\-binary\fP
 .br
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
@@ -196,14 +196,14 @@ the "unknown" value which denotes that the value could not be determined).
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -212,94 +212,94 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
+\fB\-\-configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--foreign\fP
+\fB\-\-foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
+\fB\-\-ignoreskippedcluster\fP
 .br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
 .HP
 .ad l
-\fB--logonly\fP
+\fB\-\-logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--nameprefixes\fP
+\fB\-\-nameprefixes\fP
 .br
 Add an "LVM2_" prefix plus the field name to the output. Useful
-with --noheadings to produce a list of field=value pairs that can
+with \-\-noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
 .ad b
 .HP
 .ad l
-\fB--noheadings\fP
+\fB\-\-noheadings\fP
 .br
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--nolocking\fP
+\fB\-\-nolocking\fP
 .br
 Disable locking.
 .ad b
 .HP
 .ad l
-\fB--nosuffix\fP
+\fB\-\-nosuffix\fP
 .br
-Suppress the suffix on output sizes. Use with --units
+Suppress the suffix on output sizes. Use with \-\-units
 (except h and H) if processing the output.
 .ad b
 .HP
 .ad l
-\fB-o\fP|\fB--options\fP \fIString\fP
+\fB-o\fP|\fB\-\-options\fP \fIString\fP
 .br
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
@@ -321,7 +321,7 @@ See lvmreport(7) for more information about reporting.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -330,21 +330,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--readonly\fP
+\fB\-\-readonly\fP
 .br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
@@ -358,7 +358,7 @@ actually in use.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -369,18 +369,18 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB--rows\fP
+\fB\-\-rows\fP
 .br
 Output columns as rows.
 .ad b
 .HP
 .ad l
-\fB-S\fP|\fB--select\fP \fIString\fP
+\fB-S\fP|\fB\-\-select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
-The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
+The criteria syntax is described by \fB\-\-select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
-See \fB--options help\fP for selectable object fields.
+See \fB\-\-options help\fP for selectable object fields.
 Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
@@ -388,13 +388,13 @@ used to choose items to process.
 .ad b
 .HP
 .ad l
-\fB--separator\fP \fIString\fP
+\fB\-\-separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
 .HP
 .ad l
-\fB--shared\fP
+\fB\-\-shared\fP
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
@@ -402,14 +402,14 @@ See lvmlockd(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
-\fB-O\fP|\fB--sort\fP \fIString\fP
+\fB-O\fP|\fB\-\-sort\fP \fIString\fP
 .br
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -419,50 +419,50 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--trustcache\fP
+\fB\-\-trustcache\fP
 .br
 Avoids certain device scanning during command processing. Do not use.
 .ad b
 .HP
 .ad l
-\fB--unbuffered\fP
+\fB\-\-unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
 .HP
 .ad l
-\fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
+\fB\-\-units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
-Custom units can be specified, e.g. --units 3M.
+Custom units can be specified, e.g. \-\-units 3M.
 .ad b
 .HP
 .ad l
-\fB--unquoted\fP
+\fB\-\-unquoted\fP
 .br
-When used with --nameprefixes, output values in the field=value
+When used with \-\-nameprefixes, output values in the field=value
 pairs are not quoted.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -493,7 +493,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 1e13df2..0724373 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -14,27 +14,27 @@ vgscan scans all supported LVM block devices in the system for VGs.
 .br
 .RS 4
 .ad l
-[ \fB-P\fP|\fB--partial\fP ]
+[ \fB-P\fP|\fB\-\-partial\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cache\fP ]
+[    \fB\-\-cache\fP ]
 .ad b
 .br
 .ad l
-[    \fB--ignorelockingfailure\fP ]
+[    \fB\-\-ignorelockingfailure\fP ]
 .ad b
 .br
 .ad l
-[    \fB--mknodes\fP ]
+[    \fB\-\-mknodes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--notifydbus\fP ]
+[    \fB\-\-notifydbus\fP ]
 .ad b
 .br
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
@@ -45,70 +45,70 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--cache\fP
+\fB\-\-cache\fP
 .br
 Scan all devices and send the metadata to lvmetad.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -117,47 +117,47 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignorelockingfailure\fP
+\fB\-\-ignorelockingfailure\fP
 .br
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB--mknodes\fP
+\fB\-\-mknodes\fP
 .br
 Also checks the LVM special files in /dev that are needed for active
 LVs and creates any missing ones and removes unused ones.
 .ad b
 .HP
 .ad l
-\fB--notifydbus\fP
+\fB\-\-notifydbus\fP
 .br
 Send a notification to D-Bus. The command will exit with an error
 if LVM is not built with support for D-Bus notification, or if the
@@ -165,7 +165,7 @@ notify_dbus config setting is disabled.
 .ad b
 .HP
 .ad l
-\fB-P\fP|\fB--partial\fP
+\fB-P\fP|\fB\-\-partial\fP
 .br
 When set, the tools will do their best to provide access to VGs
 that are only partially available (one or more PVs belonging
@@ -174,21 +174,21 @@ changed with this option.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB\-\-reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
@@ -199,7 +199,7 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -209,20 +209,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -244,7 +244,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index bb9e784..bdd304b 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -35,7 +35,7 @@ Split a VG by specified PVs.
 Split a VG by PVs in a specified LV.
 .br
 .P
-\fBvgsplit\fP \fB-n\fP|\fB--name\fP \fILV\fP \fIVG\fP \fIVG\fP
+\fBvgsplit\fP \fB-n\fP|\fB\-\-name\fP \fILV\fP \fIVG\fP \fIVG\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -46,31 +46,31 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP ]
+[ \fB-c\fP|\fB\-\-clustered\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP ]
+[ \fB-l\fP|\fB\-\-maxlogicalvolumes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP ]
+[ \fB-p\fP|\fB\-\-maxphysicalvolumes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
 .ad b
 .br
 .ad l
-[    \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
+[    \fB\-\-[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
 .ad b
 .RE
 
@@ -78,57 +78,57 @@ Common options for lvm:
 .
 .RS 4
 .ad l
-[ \fB-d\fP|\fB--debug\fP ]
+[ \fB-d\fP|\fB\-\-debug\fP ]
 .ad b
 .br
 .ad l
-[ \fB-h\fP|\fB--help\fP ]
+[ \fB-h\fP|\fB\-\-help\fP ]
 .ad b
 .br
 .ad l
-[ \fB-q\fP|\fB--quiet\fP ]
+[ \fB-q\fP|\fB\-\-quiet\fP ]
 .ad b
 .br
 .ad l
-[ \fB-t\fP|\fB--test\fP ]
+[ \fB-t\fP|\fB\-\-test\fP ]
 .ad b
 .br
 .ad l
-[ \fB-v\fP|\fB--verbose\fP ]
+[ \fB-v\fP|\fB\-\-verbose\fP ]
 .ad b
 .br
 .ad l
-[ \fB-y\fP|\fB--yes\fP ]
+[ \fB-y\fP|\fB\-\-yes\fP ]
 .ad b
 .br
 .ad l
-[    \fB--commandprofile\fP \fIString\fP ]
+[    \fB\-\-commandprofile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--config\fP \fIString\fP ]
+[    \fB\-\-config\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
+[    \fB\-\-driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--longhelp\fP ]
+[    \fB\-\-longhelp\fP ]
 .ad b
 .br
 .ad l
-[    \fB--profile\fP \fIString\fP ]
+[    \fB\-\-profile\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--version\fP ]
+[    \fB\-\-version\fP ]
 .ad b
 .RE
 .SH OPTIONS
 .HP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB\-\-alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
@@ -149,27 +149,27 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
+\fB-A\fP|\fB\-\-autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
+\fB-c\fP|\fB\-\-clustered\fP \fBy\fP|\fBn\fP
 .br
 Specifies the clustered property of the new VG.
 .ad b
 .HP
 .ad l
-\fB--commandprofile\fP \fIString\fP
+\fB\-\-commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
-\fB--config\fP \fIString\fP
+\fB\-\-config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
@@ -178,48 +178,48 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad b
 .HP
 .ad l
-\fB-d\fP|\fB--debug\fP ...
+\fB-d\fP|\fB\-\-debug\fP ...
 .br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
+\fB\-\-driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB-h\fP|\fB--help\fP
+\fB-h\fP|\fB\-\-help\fP
 .br
 Display help text.
 .ad b
 .HP
 .ad l
-\fB--longhelp\fP
+\fB\-\-longhelp\fP
 .br
 Display long help text.
 .ad b
 .HP
 .ad l
-\fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
+\fB-l\fP|\fB\-\-maxlogicalvolumes\fP \fINumber\fP
 .br
 Sets the maximum number of LVs allowed in a VG.
 .ad b
 .HP
 .ad l
-\fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
+\fB-p\fP|\fB\-\-maxphysicalvolumes\fP \fINumber\fP
 .br
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
-For large numbers of PVs, also see options --pvmetadatacopies,
-and --vgmetadatacopies for improving performance.
+For large numbers of PVs, also see options \-\-pvmetadatacopies,
+and \-\-vgmetadatacopies for improving performance.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB\-\-metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
@@ -228,27 +228,27 @@ can be used for accessing old data.
 .ad b
 .HP
 .ad l
-\fB-n\fP|\fB--name\fP \fIString\fP
+\fB-n\fP|\fB\-\-name\fP \fIString\fP
 .br
 Move only PVs used by the named LV.
 .ad b
 .HP
 .ad l
-\fB--profile\fP \fIString\fP
+\fB\-\-profile\fP \fIString\fP
 .br
-An alias for --commandprofile or --metadataprofile, depending
+An alias for \-\-commandprofile or \-\-metadataprofile, depending
 on the command.
 .ad b
 .HP
 .ad l
-\fB-q\fP|\fB--quiet\fP ...
+\fB-q\fP|\fB\-\-quiet\fP ...
 .br
-Suppress output and log messages. Overrides --debug and --verbose.
+Suppress output and log messages. Overrides \-\-debug and \-\-verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
 .HP
 .ad l
-\fB-t\fP|\fB--test\fP
+\fB-t\fP|\fB\-\-test\fP
 .br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
@@ -258,20 +258,20 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB-v\fP|\fB--verbose\fP ...
+\fB-v\fP|\fB\-\-verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
 .HP
 .ad l
-\fB--version\fP
+\fB\-\-version\fP
 .br
 Display version information.
 .ad b
 .HP
 .ad l
-\fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
+\fB\-\-[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
@@ -289,7 +289,7 @@ all PVs, and then to become unmanaged.
 .ad b
 .HP
 .ad l
-\fB-y\fP|\fB--yes\fP
+\fB-y\fP|\fB\-\-yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
@@ -325,7 +325,7 @@ UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
 b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
 m|M is megabytes, g|G is gigabytes, t|T is terabytes,
 p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
+(This should not be confused with the output control \-\-units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.


