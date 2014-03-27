From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:15:28 +0000 (UTC)
Subject: master - tests: more pvchange options examined
Message-ID: <20140327121528.1011560D90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ebdfcfb596bc2611c8b54d46c0a4ce6cc05ba9f
Commit:        4ebdfcfb596bc2611c8b54d46c0a4ce6cc05ba9f
Parent:        04a6918518d9c74b761a5ca74e8f67cf2b170d71
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 27 11:23:08 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:13:22 2014 +0100

tests: more pvchange options examined

---
 test/shell/pvchange-usage.sh |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index d5a2ebb..8506747 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -30,8 +30,10 @@ do
 
 # "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
 	pvchange "$dev1" -x n
+	pvchange "$dev1" -x n   # already disabled
 	check pv_field "$dev1" pv_attr  ---
 	pvchange "$dev1" -x y
+	pvchange "$dev1" -x y   # already enabled
 	check pv_field "$dev1" pv_attr  a--
 
 # 'remove pv'
@@ -46,6 +48,13 @@ vgcreate $vg1 "$dev1" "$dev2"
 pvchange -u "$dev1"
 pvchange -u "$dev2"
 check pvlv_counts $vg1 2 0 0
+
+# -a needs more params
+not pvchange -a
+# -a is searching for devs, so passing it some is error
+not pvchange -a "$dev1"
+not pvchange -u "$dev1-notfound"
+
 pvchange -u --all
 check pvlv_counts $vg1 2 0 0
 


