From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 May 2014 13:36:04 +0000 (UTC)
Subject: master - tests: dd needs to hit disk
Message-ID: <20140528133604.9932D6061F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=171a668e81d9c647677465f042775722a35c5a6e
Commit:        171a668e81d9c647677465f042775722a35c5a6e
Parent:        ba3e6e7c323a48b64720f7a182d5c8eca0a5613c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 28 15:24:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 28 15:33:41 2014 +0200

tests: dd needs to hit disk

Unsure if this is feature or bug of syncaction,
but it needs to be present physically on the media
and it ignores content of buffer cache...

(maybe lvchange should implicitely fsync all disks
that are members of raid array before starting test??)
---
 test/shell/lvchange-raid.sh |   17 +----------------
 1 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 209e094..a229154 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -157,22 +157,7 @@ run_syncaction_check() {
 
 	# Overwrite the last half of one of the PVs with crap
 	dd if=/dev/urandom of="$device" bs=1k count=$size seek=$seek
-
-	if [ -n "$THIN_POSTFIX" ]; then
-		#
-		# Seems to work fine on real devices,
-		# but can't make the system notice the bad blocks
-		# in the testsuite - especially when thin is layered
-		# on top of RAID.  In other cases, I can deactivate
-		# and reactivate and it works.  Here, even that doesn't
-		# work.
-		return 0
-		lvchange -an $vg/$2
-		lvchange -ay $vg/$2
-	else
-		lvchange -an $vg/$lv
-		lvchange -ay $vg/$lv
-	fi
+	sync
 
 	# "check" should find discrepancies but not change them
 	# 'lvs' should show results


