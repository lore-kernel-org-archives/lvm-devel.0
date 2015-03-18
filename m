From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Mar 2015 12:46:40 +0000 (UTC)
Subject: master - lvchange: disable persistent minors for pools
Message-ID: <20150318124640.E93B260C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a10a11bd54d9f33842eee8c168dc3c47aebec05b
Commit:        a10a11bd54d9f33842eee8c168dc3c47aebec05b
Parent:        95fbbf4f40e8d0e9d9565f5a25f66a8127986822
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 17 09:44:26 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 18 13:42:13 2015 +0100

lvchange: disable persistent minors for pools

There is no reason to support persistent major/minor numbers
for pool volumes - it's only meant to be supported for filesystems
(since i.e. nfs may need to keep volume on a persistent device node.)

Support for pools is now explicitely disabled and documented.
---
 WHATS_NEW                    |    1 +
 man/lvchange.8.in            |    1 +
 test/shell/lvchange-cache.sh |    4 ++++
 test/shell/lvchange-thin.sh  |    5 +++--
 tools/lvchange.c             |    5 +++++
 5 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d0a0c2d..0ce81fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Disable lvchange of major and minor of pool LVs.
   Fix pvscan --cache to not scan and read ignored metadata areas on PVs.
   Add After=iscsi-shutdown.service to blk-availability.service systemd unit.
   Disallow vgconvert from changing metadata format when lvmetad is used.
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index fbae953..6b41c81 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -279,6 +279,7 @@ Do not use this if dmeventd is already monitoring a device.
 .TP
 .BR \-M ", " \-\-persistent " {" \fIy | \fIn }
 Set to y to make the minor number specified persistent.
+Change of persistent numbers is not supported for pool volumes.
 .TP
 .BR \-p ", " \-\-permission " {" \fIr | \fIrw }
 Change access permission to read-only or read/write.
diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 9959f93..20826fb 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -18,6 +18,10 @@ lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
 lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
 lvcreate -n noncache -l 1 $vg
 
+# cannot change major minor for pools
+not lvchange --yes -M y --minor 235 --major 253 $vg/cpool
+not lvchange -M n $vg/cpool
+
 not lvchange --cachepolicy mq $vg/noncache
 not lvchange --cachesettings foo=bar $vg/noncache
 
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 4d33563..87919bc 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -54,8 +54,9 @@ lvchange -r auto $vg/$lv1
 lvchange --yes -M y --minor 234 --major 253 $vg/$lv1
 lvchange -M n $vg/$lv1
 
-lvchange --yes -M y --minor 235 --major 253 $vg/pool
-lvchange -M n $vg/pool
+# cannot change major minor for pools
+not lvchange --yes -M y --minor 235 --major 253 $vg/pool
+not lvchange -M n $vg/pool
 
 # addtag_ARG
 lvchange --addtag foo $vg/$lv1
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 5e90adc..096aae4 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -966,6 +966,11 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
+	if (arg_count(cmd, persistent_ARG) && lv_is_pool(lv)) {
+		log_error("Persistent major and minor numbers are not supported with pools.");
+		return ECMD_FAILED;
+	}
+
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
 	 * If --poll is explicitly provided use it; otherwise polling


