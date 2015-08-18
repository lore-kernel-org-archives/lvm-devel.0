From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 18 Aug 2015 20:07:25 +0000 (UTC)
Subject: master - tests: fix lockd options in sanlock-prepare
Message-ID: <20150818200725.32161602E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c09dad71fb56710caa375404ef9974d72079422e
Commit:        c09dad71fb56710caa375404ef9974d72079422e
Parent:        d08427030dc68d827f7ad5be83b81063f613758c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 18 14:50:45 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 18 15:06:49 2015 -0500

tests: fix lockd options in sanlock-prepare

---
 test/shell/sanlock-prepare.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/sanlock-prepare.sh b/test/shell/sanlock-prepare.sh
index 289a481..401d6d7 100644
--- a/test/shell/sanlock-prepare.sh
+++ b/test/shell/sanlock-prepare.sh
@@ -80,7 +80,7 @@ echo "0 `blockdev --getsize $GL_LOOP` linear $GL_LOOP 0" | dmsetup create GL_DEV
 
 prepare_lvmlockd_sanlock
 
-vgcreate --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' --lock-type sanlock --lock-gl enable --lock-opt wait glvg $GL_DEV
+vgcreate --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' --lock-type sanlock glvg $GL_DEV
 
 vgs --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' -o+locktype,lockargs glvg
 


