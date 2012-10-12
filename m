From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 16:00:10 +0000 (UTC)
Subject: master - test: update global_filter
Message-ID: <20121012160010.68FADA1059@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=98124361ae19b049842d9c8263be6216ee5a6ed8
Commit:        98124361ae19b049842d9c8263be6216ee5a6ed8
Parent:        bb867abe11c61db70769570548fd410040aee513
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 17:59:11 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 17:59:11 2012 +0200

test: update global_filter

use simplier filter for test suite
---
 test/shell/mdata-strings.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 85d0b79..16e9360 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -14,7 +14,7 @@
 . lib/test
 
 aux prepare_devs 2
-aux lvmconf 'devices/global_filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]'
+aux lvmconf 'devices/global_filter = [ "a|.*LVMTEST.*dev/mapper/.*pv[0-9_]*$|", "r|.*|" ]'
 
 # for udev impossible to create
 pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"


