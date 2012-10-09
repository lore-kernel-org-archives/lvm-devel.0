From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  9 Oct 2012 08:38:43 +0000 (UTC)
Subject: master - test: ignore modprobe failure
Message-ID: <20121009083843.EA73812EA@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0d34f383df7a00902e8d0512a815fd764ee05a9
Commit:        f0d34f383df7a00902e8d0512a815fd764ee05a9
Parent:        9ff2f1a3dbaa6f77b1693b7a9cf540a902cf618d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 9 10:37:37 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 9 10:37:37 2012 +0200

test: ignore modprobe failure

If the system doesn't have modprobe but happens to have modules
loaded, allow version testing.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 107afc1..6cfd6db 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -506,7 +506,7 @@ wait_for_sync() {
 target_at_least()
 {
 	case "$1" in
-	  dm-*) modprobe "$1" ;;
+	  dm-*) modprobe "$1" || true ;;
 	esac
 
 	local version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)


