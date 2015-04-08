From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Apr 2015 21:20:32 +0000 (UTC)
Subject: master - tests: put "" around dev path
Message-ID: <20150408212032.B93E46055A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5b34f0f1bf38807bdbed2855516f9b2ceebf7b7
Commit:        a5b34f0f1bf38807bdbed2855516f9b2ceebf7b7
Parent:        4459413225eaa10278bd47fc33e30b85794ad7f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 8 22:43:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 23:19:37 2015 +0200

tests: put "" around dev path

---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index cc102fe..3232074 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -513,8 +513,8 @@ disable_dev() {
 		echo "Disabling device $dev ($maj:$min)"
 		notify="$notify $maj:$min"
 		if test -n "$error"; then
-		    echo 0 10000000 error | dmsetup load $dev
-		    dmsetup resume $dev
+		    echo 0 10000000 error | dmsetup load "$dev"
+		    dmsetup resume "$dev"
 		else
 		    dmsetup remove -f "$dev" 2>/dev/null || true
 		fi


