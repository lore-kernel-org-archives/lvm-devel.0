From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:11:47 +0000 (UTC)
Subject: master - tests: update vgchange -c
Message-ID: <20140611091147.30E2F60EE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f81b7c55c612ab24ade8d637517a33298b2cc94
Commit:        3f81b7c55c612ab24ade8d637517a33298b2cc94
Parent:        f845afe7cfc98ac1cde86e25d60c6eeeb530eebe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 10 13:13:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 11:11:10 2014 +0200

tests: update vgchange -c

Vgchange now detects runnig clvmd - so update test to reflect this.
---
 test/shell/vgchange-usage.sh |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 54734c1..6ba3f69 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -88,15 +88,19 @@ vgcreate -cn $vg "$dev1" "$dev2" "$dev3"
 fail vgchange -cy |& tee out
 grep "y/n" out
 check vg_attr_bit cluster $vg "-"
-vgchange -cy $vg
-fail vgchange -cy $vg
 
 # check on cluster
 # either skipped as clustered (non-cluster), or already clustered (on cluster)
 if test -e LOCAL_CLVMD ; then
+	vgchange -cy $vg
+	fail vgchange -cy $vg
 	check vg_attr_bit cluster $vg "c"
 	vgchange -cn $vg
 else
+	# no clvmd is running
+	fail vgchange -cy $vg
+	vgchange --yes -cy $vg
+	fail vgchange --yes -cy $vg
 	fail vgs $vg |& tee out
 	grep "Skipping clustered volume group" out
 	vgs --ignoreskippedcluster $vg |& tee out


