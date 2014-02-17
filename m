From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Feb 2014 21:26:46 +0000 (UTC)
Subject: master - tests: drop more debug.log
Message-ID: <20140217212646.98D4B60520@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0be6caba6e4251200eb888a2686ddf9af8065d6c
Commit:        0be6caba6e4251200eb888a2686ddf9af8065d6c
Parent:        18cac1654045a8eebc09ba418f2f8b4f6ebd9556
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 15 20:40:57 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 17 22:25:53 2014 +0100

tests: drop more debug.log

Avoid login result from last lvm command when target_at_least fails.
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9420528..7587c4b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -691,6 +691,7 @@ can_use_16T()
 # i.e.   dm_target_at_least  dm-thin-pool  1 0
 target_at_least()
 {
+	rm -f debug.log
 	case "$1" in
 	  dm-*) modprobe "$1" || true ;;
 	esac


