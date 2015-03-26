From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Mar 2015 14:11:33 +0000 (UTC)
Subject: master - tests: avoid multiple pids
Message-ID: <20150326141133.AD2B96113C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7ebab765761098058c436a3543ecbff00ad171a
Commit:        b7ebab765761098058c436a3543ecbff00ad171a
Parent:        0bffd99daa6510f80c918a23187b638260e9e634
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 26 14:12:34 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 26 15:10:04 2015 +0100

tests: avoid multiple pids

On some systems (parisc) pgrep prints more then 1 pid
(all thread IDs are printed)
So print only leading pid and avoid 'kill' being confused.
---
 test/shell/dmeventd-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 4344e82..022b8a8 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -48,7 +48,7 @@ if test -n "$abs_top_builddir"; then
 fi
 
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
-pgrep dmeventd >LOCAL_DMEVENTD
+pgrep -o dmeventd >LOCAL_DMEVENTD
 not grep 'already monitored' lvchange.out
 
 vgremove -ff $vg


