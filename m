From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:19 +0000 (UTC)
Subject: master - tests: without delay_dev skip some checks
Message-ID: <20151113101919.572E960FDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea1814cea8fe45c7f9dd861642e65701a00f8c03
Commit:        ea1814cea8fe45c7f9dd861642e65701a00f8c03
Parent:        6dadebb1e45b0adc63380b5c61fb37f6d7ffee5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 13 10:00:57 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:07 2015 +0100

tests: without delay_dev skip some checks

When delay_dev is missing these tests are just racy.
---
 test/shell/pvmove-resume-2.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index ff3806f..c8643e4 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -99,7 +99,7 @@ lvchange_all() {
 	if test -e LOCAL_LVMPOLLD; then
 		aux lvmpolld_dump | tee lvmpolld_dump.txt
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0" || should false
-	else
+	elif test -e HAVE_DM_DELAY; then
 		test $(aux count_processes_with_tag) -eq $1 || should false
 	fi
 }
@@ -110,7 +110,7 @@ vgchange_single() {
 	if test -e LOCAL_LVMPOLLD; then
 		aux lvmpolld_dump | tee lvmpolld_dump.txt
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
-	else
+	elif test -e HAVE_DM_DELAY; then
 		test $(aux count_processes_with_tag) -eq $1
 	fi
 }


