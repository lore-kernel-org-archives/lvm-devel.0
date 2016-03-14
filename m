From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Mar 2016 22:46:56 +0000 (UTC)
Subject: master - tests: use own PID path for lvmetad checking
Message-ID: <20160314224656.66A8B60702@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d5b9deff21991f0b26240ae4395ee12e76096c5
Commit:        0d5b9deff21991f0b26240ae4395ee12e76096c5
Parent:        7daba90fa3c2cec085170b1c18f63d7877e483da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 14 23:16:45 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 14 23:45:45 2016 +0100

tests: use own PID path for lvmetad checking

Do not try to check PID of running lvmetad and use own path.
---
 test/lib/inittest.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index a2dcf01..a453ee6 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -114,6 +114,7 @@ if test -n "$LVM_TEST_LVMETAD" ; then
 	aux prepare_lvmetad
 else
 	# lvmetad prepares its own lvmconf
+	export LVM_LVMETAD_PIDFILE="$TESTDIR/non-existing-file"
 	aux lvmconf
 	aux prepare_clvmd
 fi


