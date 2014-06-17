From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:44 +0000 (UTC)
Subject: master - tests: wait for udev
Message-ID: <20140617132444.0D35361207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fb19f37fe6419fd2c22c04ffd71e0ac4a0bca36
Commit:        6fb19f37fe6419fd2c22c04ffd71e0ac4a0bca36
Parent:        0558b1a0869f9a68d78e80140500874756c70e4d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 16 13:37:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:43:04 2014 +0200

tests: wait for udev

Before test exits, wait for udev.
---
 test/lib/aux.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f6f0d0b..76b93ef 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -200,6 +200,9 @@ teardown_devs() {
 			for i in "${stray_loops[@]}" ; do losetup -d $i ; done
 		}
 	}
+
+	# Leave test when udev processed all removed devices
+	udev_wait
 }
 
 kill_sleep_kill_() {


