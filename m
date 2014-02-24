From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 24 Feb 2014 16:41:20 +0000 (UTC)
Subject: master - test: Add cache[pool] support to lv_tree_devices_ test suite function.
Message-ID: <20140224164120.5D84560F12@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fdb7356d6a9be43678c9d001725aef6dca02d178
Commit:        fdb7356d6a9be43678c9d001725aef6dca02d178
Parent:        f3d1debb18cc58d36eed75ba6610e5a3ef498d12
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Feb 24 10:40:00 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Feb 24 10:40:00 2014 -0600

test: Add cache[pool] support to lv_tree_devices_ test suite function.

---
 test/lib/get.sh |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index 5dd5451..babc4c9 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -70,6 +70,13 @@ lv_tree_devices_() {
 		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv data_lv)"
 		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv metadata_lv)"
 		;;
+	cache)
+		lv_tree_devices_ "$1" "$(lv_devices $lv)"
+		;;
+	cache-pool)
+		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv data_lv)"
+		lv_tree_devices_ "$1" "$(lv_field_lv_ $lv metadata_lv)"
+		;;
 	esac
 }
 


