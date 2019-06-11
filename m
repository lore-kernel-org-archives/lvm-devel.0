From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jun 2019 10:44:33 -0400
Subject: master - tests: correct checked target name
Message-ID: <201906111444.x5BEiXm3031816@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c9203a6106c7f9d66d7872e5709f5e02d246c0e3
Commit:        c9203a6106c7f9d66d7872e5709f5e02d246c0e3
Parent:        e225bf59ffdad0de1bb976ffdb65d77979cb5381
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 16:40:44 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 16:43:14 2019 +0200

tests: correct checked target name

So when the target name happened to be a suffix of another one,
the grep was filtering incorrect line
(i.e. dm-cache && dm-writecache) - so do a line head matching.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b178ab7..040c8f2 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1421,7 +1421,7 @@ target_at_least() {
 	fi
 
 	local version
-	version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
+	version=$(dmsetup targets 2>/dev/null | grep "^${1##dm-} " 2>/dev/null)
 	version=${version##* v}
 
 	version_at_least "$version" "${@:2}" || {


