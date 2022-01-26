From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Jan 2022 14:10:32 +0000 (GMT)
Subject: main - man: doc writecache profile support
Message-ID: <20220126141032.79F3838515FC@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b95506815fa149cf135687cbe047b7bdfcd6e00f
Commit:        b95506815fa149cf135687cbe047b7bdfcd6e00f
Parent:        d8dbabb28e674e9f2aac2716b235f27f1d333e1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 24 14:50:09 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 26 15:09:58 2022 +0100

man: doc writecache profile support

---
 man/lvmcache.7_main | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 48cf7b492..8d7d3d17b 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -299,6 +299,39 @@ perform.  If not done beforehand, the splitcache command enables the
 cleaner mode and waits for flushing to complete before detaching the
 writecache.  Adding cleaner=0 to the splitcache command will skip the
 cleaner mode, and any required flushing is performed in device suspend.
+
+.SS dm-writecache using metadata profiles
+
+Writecache allows to set a variety of options. Lots of these settings
+can be specified in lvm.conf or profile settings. You can prepare
+a number of different profiles in the \fI#DEFAULT_SYS_DIR#/profile\fP directory
+and just specify the metadata profile file name when writecaching LV.
+.P
+.I Example
+.nf
+# cat <<EOF > #DEFAULT_SYS_DIR#/profile/cache_writecache.profile
+allocation {
+.RS
+cache_settings {
+.RS
+writecache {
+.RS
+high_watermark=60
+writeback_jobs=1024
+.RE
+}
+.RE
+}
+.RE
+}
+EOF
+.P
+
+# lvcreate -an -L10G --name wcache vg /dev/fast_ssd
+# lvcreate --type writecache -L10G --name main  --cachevol wcache \\
+   --metadataprofile cache_writecache vg /dev/slow_hdd
+.fi
+
 .
 .SS dm-cache with separate data and metadata LVs
 .


