From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Jul 2015 09:49:51 +0000 (UTC)
Subject: master - tests: add test for 454782f (select with synonyms for string field types)
Message-ID: <20150702094951.2022A60C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eaa0d927a4490c632b02a223cb426d7e483d9055
Commit:        eaa0d927a4490c632b02a223cb426d7e483d9055
Parent:        454782f1a3cf41148711773ae820e646bd2fd95f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 2 11:46:58 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 2 11:46:58 2015 +0200

tests: add test for 454782f (select with synonyms for string field types)

---
 test/shell/select-report.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index a79457e..cd3f452 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -185,6 +185,8 @@ sel lv 'lv_minor=undefined' vol1 vol2 abc orig snap
 sel lv 'lv_minor=undef' vol1 vol2 abc orig snap
 sel lv 'lv_minor=unknown' vol1 vol2 abc orig snap
 sel lv 'lv_minor=254' xyz
+# also test synonym for string field type
+sel lv 'seg_monitor=undefined' vol1 vol2 abc abc orig snap xyz
 
 # if size unit not spefied, the 'm' (MiB) unit is used by default
 sel lv 'lv_size=8' vol1


