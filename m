From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 09:02:20 +0000 (UTC)
Subject: master - tests: add test for minimum mda size
Message-ID: <20151030090220.6BD9160238@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a3b64e81ad1988f4143b5a4b4ac06eaf3035e58
Commit:        9a3b64e81ad1988f4143b5a4b4ac06eaf3035e58
Parent:        c2e88d1107c496d2c1b39bbbfb9795e88b3a6b60
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 30 10:02:00 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 10:02:00 2015 +0100

tests: add test for minimum mda size

---
 test/shell/pvcreate-usage.sh |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 5b74ed3..c6aab26 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -12,6 +12,8 @@
 test_description='Test pvcreate option values'
 SKIP_WITH_LVMPOLLD=1
 PAGESIZE=$(getconf PAGESIZE)
+# MDA_SIZE_MIN defined in lib/format_text/layout.h
+MDA_SIZE_MIN=$((8*$PAGESIZE))
 
 . lib/inittest
 
@@ -23,6 +25,13 @@ not pvcreate --setphysicalvolumesize -1024 "$dev1"
 #COMM 'pvcreate rejects negative metadatasize'
 not pvcreate --metadatasize -1024 "$dev1"
 
+#COMM 'pvcreate rejects metadatasize that is less than minimum size'
+not pvcreate --dataalignment $((${MDA_SIZE_MIN}/2))b --metadatasize $((${MDA_SIZE_MIN}/2))b "$dev1" 2>err
+grep "Metadata area size too small" err
+
+#COMM 'pvcreate accepts metadatasize that is at least the minimum size'
+pvcreate --dataalignment ${MDA_SIZE_MIN}b --metadatasize ${MDA_SIZE_MIN}b "$dev1"
+
 # x. metadatasize 0, defaults to 255
 # FIXME: unable to check default value, not in reporting cmds
 # should default to 255 according to code


