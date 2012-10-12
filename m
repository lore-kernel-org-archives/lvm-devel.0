From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 15:36:12 +0000 (UTC)
Subject: master - test: typo fix from last commit
Message-ID: <20121012153612.B02ED3323@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bb867abe11c61db70769570548fd410040aee513
Commit:        bb867abe11c61db70769570548fd410040aee513
Parent:        45b1fcdb4e65ff55ba40df03df56c65d6c06aa76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 17:35:44 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 17:35:44 2012 +0200

test: typo fix from last commit

---
 test/shell/mdata-strings.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index c98b364..85d0b79 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -14,7 +14,7 @@
 . lib/test
 
 aux prepare_devs 2
-axu lvmconf 'devices/global_filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]'
+aux lvmconf 'devices/global_filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]'
 
 # for udev impossible to create
 pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"


