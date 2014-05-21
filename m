From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 10:01:52 +0000 (UTC)
Subject: master - tests: notify loop needs maj:min
Message-ID: <20140521100152.9C24060DFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c34c33d9ba69f1458932e468caa10846ebb4e970
Commit:        c34c33d9ba69f1458932e468caa10846ebb4e970
Parent:        cbdb8fa58925f64cf1da9de9ec00e878fe83c2d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 12:00:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 12:00:32 2014 +0200

tests: notify loop needs maj:min

Missed in previous commit.
---
 test/lib/aux.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 400a49d..e422fa0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -417,6 +417,8 @@ disable_dev() {
 	finish_udev_transaction
 
 	for dev in "$@"; do
+		maj=$(($(stat -L --printf=0x%t "$dev")))
+		min=$(($(stat -L --printf=0x%T "$dev")))
 		notify_lvmetad --major "$maj" --minor "$min"
 	done
 }


