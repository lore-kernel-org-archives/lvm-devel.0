From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 15:29:08 +0000 (UTC)
Subject: master - test: move global_filter only to mdata_string test
Message-ID: <20121012152908.2329A14EC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45b1fcdb4e65ff55ba40df03df56c65d6c06aa76
Commit:        45b1fcdb4e65ff55ba40df03df56c65d6c06aa76
Parent:        0f155e699c67b98cdf6613dcb9fad8d175af7077
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 17:27:29 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 17:27:29 2012 +0200

test: move global_filter only to mdata_string test

Tries to help with lvmetad test and pvdisplay and unknown device.
---
 test/lib/aux.sh             |    1 -
 test/shell/mdata-strings.sh |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 07326ec..103318a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -410,7 +410,6 @@ lvmconf() {
             cat > CONFIG_VALUES <<-EOF
 devices/dir = "$DM_DEV_DIR"
 devices/scan = "$DM_DEV_DIR"
-devices/global_filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/cache_dir = "$TESTDIR/etc"
 devices/sysfs_scan = 0
diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 574334c..c98b364 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -14,6 +14,7 @@
 . lib/test
 
 aux prepare_devs 2
+axu lvmconf 'devices/global_filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]'
 
 # for udev impossible to create
 pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"


