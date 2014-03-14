From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Mar 2014 09:42:09 +0000 (UTC)
Subject: master - tests: quick update of location of pid file
Message-ID: <20140314094209.1027D612B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=900cb6717b9d06e2b40049e4da2b25e8b98375a7
Commit:        900cb6717b9d06e2b40049e4da2b25e8b98375a7
Parent:        551b6b799867860fc6a437be5298bc74b814ab19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 14 10:40:48 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 14 10:40:48 2014 +0100

tests: quick update of location of pid file

Until better fix is put in - replace with /run.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c3adb56..7d13e8d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -68,7 +68,7 @@ prepare_dmeventd() {
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
-	while ! test -e "/var/run/dmeventd.pid"; do echo -n .; sleep .2; done # wait for the socket
+	while ! test -e "/run/dmeventd.pid"; do echo -n .; sleep .2; done # wait for the socket
 	echo ok
 }
 


