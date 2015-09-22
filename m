From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Sep 2015 11:33:58 +0000 (UTC)
Subject: master - lvmconf: set locking_type=2 if external library is requested
Message-ID: <20150922113358.6CCBD60E42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=001f747963d66e4cff8e827afb710961193b9f03
Commit:        001f747963d66e4cff8e827afb710961193b9f03
Parent:        2081071bee76bcd168cccbf039a2fac663048c10
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 22 13:32:47 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 22 13:33:12 2015 +0200

lvmconf: set locking_type=2 if external library is requested

Also, set safe use_lvmetad=0 for external locking (locking_type=2)
similarly to locking_type=3.
---
 WHATS_NEW          |    1 +
 scripts/lvmconf.sh |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cade4b2..ae40c0b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.132 - 
 ======================================
+  Fix lvmconf to set locking_type=2 if external locking library is requested.
   Remove verbose message when rescanning an unchanged device. (2.02.119)
   Add origin_uuid, mirror_log_uuid, move_pv_uuid, convert_lv_uuid report fields.
   Add pool_lv_uuid, metadata_lv_uuid, data_lv_uuid reporting fields.
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index c3c1700..fa6bc9c 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -133,6 +133,11 @@ function parse_args
                 exit 1
         esac
     done
+
+    if [ "$LOCKINGLIBDIR" -o "$LOCKINGLIB" ]; then
+        LOCKING_TYPE=2
+        USE_LVMETAD=0
+    fi
 }
 
 function validate_args


