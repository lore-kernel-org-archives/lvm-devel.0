From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  3 Nov 2015 19:28:26 +0000 (UTC)
Subject: master - tests: skip duplicate vg names test with lvmetad
Message-ID: <20151103192826.99C7160139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19feda2c95facee43ed1b470492e1d22e0f5dfdd
Commit:        19feda2c95facee43ed1b470492e1d22e0f5dfdd
Parent:        4e6377f5bab83e2740bbcdd1e7e3d654e912e937
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 30 16:12:06 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 3 13:25:35 2015 -0600

tests: skip duplicate vg names test with lvmetad

If two PVs have different VGs with the same name
(different uuids), one of the VGs is ignored by
lvmetad.  A FIXME exists in lvmetad to find a
better response.
---
 test/shell/process-each-duplicate-vgnames.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 90d3e23..5cdf32b 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -7,6 +7,7 @@
 
 test_description='Test vgs with duplicate vg names'
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMETAD=1
 
 . lib/inittest
 


