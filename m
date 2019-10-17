From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:05:21 -0400
Subject: master - tests: skip when raid is not present
Message-ID: <201910171105.x9HB5LH8023669@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f07e5c1fe43524ec6f9da6afaf95c5b328972703
Commit:        f07e5c1fe43524ec6f9da6afaf95c5b328972703
Parent:        ec85dfe0f8096ee486c39c22b740f3938932707e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 21:58:39 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:50 2019 +0200

tests: skip when raid is not present

---
 test/shell/lvextend-raid.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 8988411..1c0e9c6 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -15,6 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_raid 1 3 0 || skip
 v1_15_0=0
 aux have_raid 1 15 0 && v1_15_0=1
 


