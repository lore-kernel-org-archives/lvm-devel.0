From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:46 +0000 (UTC)
Subject: master - tests: do not use EPOCH for get wrapper
Message-ID: <20160505220146.3226360C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08aeea6a126d71843a2c133b15565d8efb664ae2
Commit:        08aeea6a126d71843a2c133b15565d8efb664ae2
Parent:        07c1694ff59fd760a602fb1425c5c99bc0bd33ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 3 21:22:34 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:55:20 2016 +0200

tests: do not use EPOCH for get wrapper

Avoid poluting filesystem with debug.log_DEBUG for get wrapper
---
 test/lib/get.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index 74ee7e8..f650417 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -103,4 +103,5 @@ first_extent_sector() {
 
 #set -x
 unset LVM_VALGRIND
+unset LVM_LOG_FILE_EPOCH
 "$@"


