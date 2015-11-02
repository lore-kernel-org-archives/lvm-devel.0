From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Mon,  2 Nov 2015 13:41:43 +0000 (UTC)
Subject: master - test: api subdirectory is needed in PATH by pytest
Message-ID: <20151102134143.7AB1E61056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf06d942b8aad5643fe0a20be49279d06f3bee62
Commit:        cf06d942b8aad5643fe0a20be49279d06f3bee62
Parent:        83d3cc76f3d4bc7b2be3b61cc1fd20f2cd5bbf85
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Nov 2 14:16:46 2015 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Nov 2 14:16:46 2015 +0100

test: api subdirectory is needed in PATH by pytest

---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index f258cde..81b8cc7 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -270,7 +270,7 @@ lib/paths-installed: lib/paths-common
 	$(RM) $@-t
 	cat lib/paths-common > $@-t
 	echo 'installed_testsuite=1' >> $@-t
-	echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:$$PATH' >> $@-t
+	echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:@datadir@/lvm2-testsuite/api:$$PATH' >> $@-t
 	mv $@-t $@
 
 lib/paths: lib/paths-common


