From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 12:55:25 +0000 (UTC)
Subject: master - tests: add get first_extent_sector
Message-ID: <20150403125525.DE9E260353@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd84389c6867d8d1f1a238361e0d12f01be7a32f
Commit:        bd84389c6867d8d1f1a238361e0d12f01be7a32f
Parent:        308f9bcc18d6c3b5f56b77dedacff4edafeb86fd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 14:20:03 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 14:20:03 2015 +0200

tests: add  get first_extent_sector

Trvial function to figure out sector position of 1st. extent.
---
 test/lib/get.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index b6fbf82..ef1ddc4 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -87,6 +87,10 @@ lv_tree_devices() {
 	lv_tree_devices_ "$@" | sort | uniq
 }
 
+first_extent_sector() {
+	pv_field "$@" pe_start --units s --nosuffix
+}
+
 #set -x
 unset LVM_VALGRIND
 "$@"


