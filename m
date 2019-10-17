From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:05:24 -0400
Subject: master - tests: cachevol needs FORMAT2
Message-ID: <201910171105.x9HB5Oqd023680@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4f860f79ff7c5bb35520776f5906ae51442d5920
Commit:        4f860f79ff7c5bb35520776f5906ae51442d5920
Parent:        f07e5c1fe43524ec6f9da6afaf95c5b328972703
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 21:58:57 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:50 2019 +0200

tests: cachevol needs FORMAT2

FORMAT2 is mandatory with cachevols...
---
 test/shell/cache-single-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/cache-single-thin.sh b/test/shell/cache-single-thin.sh
index 2547502..6b478fb 100644
--- a/test/shell/cache-single-thin.sh
+++ b/test/shell/cache-single-thin.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_cache 1 3 0 || skip
+aux have_cache 1 10 0 || skip
 aux have_thin 1 0 0 || skip
 
 aux prepare_devs 5 80


