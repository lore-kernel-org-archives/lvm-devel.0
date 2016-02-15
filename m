From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:59 +0000 (UTC)
Subject: master - tests: fix tests checking pv_attr - there's a new bit now
Message-ID: <20160215120859.74AFE60DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ad93874d63d67ea375b37b7014d782476dab88d
Commit:        8ad93874d63d67ea375b37b7014d782476dab88d
Parent:        a4e25f4381284967467a1103d67e3cdbdd2cdf82
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 12 12:05:59 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

tests: fix tests checking pv_attr - there's a new bit now

---
 lib/format_text/format-text.c |    3 +++
 test/shell/pvchange-usage.sh  |   10 +++++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 666357c..72ca198 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1447,6 +1447,9 @@ static int _text_pv_needs_rewrite(const struct format_type *fmt, struct physical
 
 	*needs_rewrite = 0;
 
+	if (!pv->is_labelled)
+		return 1;
+
 	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
 		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
 		return 0;
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index b6fbebd..ce44d84 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -23,11 +23,11 @@ aux prepare_pvs 4
 
 # check 'allocatable' pv attribute
 pvcreate "$dev1"
-check pv_field "$dev1" pv_attr ---
+check pv_field "$dev1" pv_attr ----
 vgcreate $vg1 "$dev1"
-check pv_field "$dev1" pv_attr a--
+check pv_field "$dev1" pv_attr a--u
 pvchange --allocatable n "$dev1"
-check pv_field "$dev1" pv_attr ---
+check pv_field "$dev1" pv_attr ---u
 vgremove -ff $vg1
 not pvchange --allocatable y "$dev1"
 pvremove -ff "$dev1"
@@ -50,10 +50,10 @@ do
 # "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
 	pvchange "$dev1" -x n
 	pvchange "$dev1" -x n   # already disabled
-	check pv_field "$dev1" pv_attr  ---
+	check pv_field "$dev1" pv_attr  ---u
 	pvchange "$dev1" -x y
 	pvchange "$dev1" -x y   # already enabled
-	check pv_field "$dev1" pv_attr  a--
+	check pv_field "$dev1" pv_attr  a--u
 
 # check we are able to change number of managed metadata areas
 	if test $mda -gt 0 ; then


