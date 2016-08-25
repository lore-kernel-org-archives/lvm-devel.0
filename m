From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 25 Aug 2016 14:25:34 +0000 (UTC)
Subject: master - tests: also fix typo in report/columns_as_rows in tests
Message-ID: <20160825142534.67E6760AC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc93f10892187e20f9553b2d0c953cc420fd379d
Commit:        fc93f10892187e20f9553b2d0c953cc420fd379d
Parent:        e758d722c7719fba91ae62122fb0359a395f0327
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 25 16:25:23 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 25 16:25:23 2016 +0200

tests: also fix typo in report/columns_as_rows in tests

---
 test/shell/profiles.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index 037b306..562b7b1 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -59,7 +59,7 @@ aux profileconf valid_cmd_profile 'global/units = "h"' \
                                   'report/separator = " "' \
                                   'report/prefixes = 0' \
                                   'report/quoted = 1' \
-                                  'report/colums_as_rows = 0' \
+                                  'report/columns_as_rows = 0' \
                                   'report/devtypes_sort = "devtype_name"' \
                                   'report/devtypes_cols = "devtype_name,devtype_max_partitions,devtype_description"' \
                                   'report/devtypes_cols_verbose = "devtype_name,devtype_max_partitions,devtype_description"' \


