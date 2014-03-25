From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:55 +0000 (UTC)
Subject: master - tests: argless pvremove
Message-ID: <20140325102355.B878360F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db1d4ba4ac267d32ef0c8c96d0e1785863d40f0a
Commit:        db1d4ba4ac267d32ef0c8c96d0e1785863d40f0a
Parent:        04861b9bed41a2e907fca6f71acbf4c39cfebfd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 10:01:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:23:00 2014 +0100

tests: argless pvremove

---
 test/shell/pvremove-usage.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index 4f7b35f..52f04b8 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -15,6 +15,9 @@ aux prepare_devs 3
 pvcreate "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
 pvcreate --metadatacopies 2 "$dev3"
+
+# Fails without give argument
+not pvremove
 pvremove "$dev2"
 
 # failing, but still removing everything what can be removed


