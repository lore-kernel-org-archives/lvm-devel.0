From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Jul 2016 13:49:30 +0000 (UTC)
Subject: master - tests: require better cache driver
Message-ID: <20160715134930.B31C160D2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a57bf37cdb89aced30bf27d61e87388704a7d9c6
Commit:        a57bf37cdb89aced30bf27d61e87388704a7d9c6
Parent:        12925d8b70c88e1a7a98e69ab896eb16ed2602fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 14 13:40:22 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 15 15:49:01 2016 +0200

tests: require better cache driver

Version 1.4 can't handle this test without killing itself.
---
 test/shell/lvchange-cache-mode.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-cache-mode.sh b/test/shell/lvchange-cache-mode.sh
index 239960c..947034b 100644
--- a/test/shell/lvchange-cache-mode.sh
+++ b/test/shell/lvchange-cache-mode.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_cache 1 3 0 || skip
+aux have_cache 1 5 0 || skip
 
 aux prepare_vg 2
 


