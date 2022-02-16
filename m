From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Feb 2022 21:40:06 +0000 (GMT)
Subject: main - man lvmcache: add more writecache cachesettings info
Message-ID: <20220216214006.00DF0385840E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec2119beddde9e38681cb096b93048ee25034c1e
Commit:        ec2119beddde9e38681cb096b93048ee25034c1e
Parent:        d4a0816a5824dc375d662e76823ee8ed77bb9983
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 16 15:21:09 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 16 15:21:09 2022 -0600

man lvmcache: add more writecache cachesettings info

---
 man/lvmcache.7_main | 51 +++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 39 insertions(+), 12 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 8d7d3d17b..dddd33cfa 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -243,15 +243,40 @@ can be used.
 .
 .SS dm-writecache settings
 .
-Tunable parameters can be passed to the dm-writecache kernel module using
-the --cachesettings option when caching is started, e.g.
+To specify dm-writecache tunable settings on the command line, use:
+.br
+--cachesettings 'option=N' or
+.br
+--cachesettings 'option1=N option2=N ...'
+.P
+For example, --cachesettings 'high_watermark=90 writeback_jobs=4'.
+.P
+To include settings when caching is started, run:
 .P
 .nf
 # lvconvert --type writecache --cachevol fast \\
-	--cachesettings 'high_watermark=N writeback_jobs=N' vg/main
+	--cachesettings 'option=N' vg/main
+.fi
+.P
+To change settings for an existing writecache, run:
+.P
+.nf
+# lvchange --cachesettings 'option=N' vg/main
+.fi
+.P
+To clear all settings that have been applied, run:
+.P
+.nf
+# lvchange --cachesettings '' vg/main
+.fi
+.P
+To view the settings that are applied to a writecache LV, run:
+.P
+.nf
+# lvs -o cachesettings vg/main
 .fi
 .P
-Tunable options are:
+Tunable settings are:
 .
 .TP
 high_watermark = <percent>
@@ -301,11 +326,14 @@ writecache.  Adding cleaner=0 to the splitcache command will skip the
 cleaner mode, and any required flushing is performed in device suspend.
 
 .SS dm-writecache using metadata profiles
-
-Writecache allows to set a variety of options. Lots of these settings
-can be specified in lvm.conf or profile settings. You can prepare
-a number of different profiles in the \fI#DEFAULT_SYS_DIR#/profile\fP directory
-and just specify the metadata profile file name when writecaching LV.
+.
+In addition to specifying writecache settings on the command line, they
+can also be set in lvm.conf, or in a profile file, using the
+allocation/cache_settings/writecache config structure shown below.
+.P
+It's possible to prepare a number of different profile files in the
+\fI#DEFAULT_SYS_DIR#/profile\fP directory and specify the file name
+of the profile when starting writecache.
 .P
 .I Example
 .nf
@@ -327,11 +355,10 @@ writeback_jobs=1024
 EOF
 .P
 
-# lvcreate -an -L10G --name wcache vg /dev/fast_ssd
-# lvcreate --type writecache -L10G --name main  --cachevol wcache \\
+# lvcreate -an -L10G --name fast vg /dev/fast_ssd
+# lvcreate --type writecache -L10G --name main  --cachevol fast \\
    --metadataprofile cache_writecache vg /dev/slow_hdd
 .fi
-
 .
 .SS dm-cache with separate data and metadata LVs
 .


