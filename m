From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Nov 2013 10:50:09 +0000 (UTC)
Subject: master - tests: skip raid test on 3.12.0
Message-ID: <20131119105009.BC32360D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0b061cdbc4856cf6f5b43bd9ae835e678440890
Commit:        b0b061cdbc4856cf6f5b43bd9ae835e678440890
Parent:        fe609141a894d33b92a6eb5fb9b5ee62bdc6c4ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 19 11:47:28 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 19 11:49:33 2013 +0100

tests: skip raid test on 3.12.0

3.12.0 kernel prevents raid test to be usable,
leaving unremovable devices in table.

This needs to be fixed ASAP, meanwhile disable test to make
test machines at least usable.
---
 test/lib/aux.sh              |    6 ++++++
 test/shell/lvconvert-raid.sh |    5 +----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6f21e8b..4ef1132 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -689,6 +689,12 @@ target_at_least()
 	  dm-*) modprobe "$1" || true ;;
 	esac
 
+	if test "$1" = dm-raid; then
+		case "$(uname -r)" in
+		  3.12.0*) return 1 ;;
+		esac
+	fi
+
 	local version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
 	version=${version##* v}
 	shift
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 680710e..0bdb023 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -22,10 +22,7 @@ get_image_pvs() {
 ########################################################
 # MAIN
 ########################################################
-if ! aux target_at_least dm-raid 1 2 0; then
-	dmsetup targets | grep raid
-	skip
-fi
+aux target_at_least dm-raid 1 2 0 || skip
 
 # 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
 aux prepare_pvs 9 80


