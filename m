From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 11 Oct 2012 20:47:49 +0000 (UTC)
Subject: master - lvmdump: Fix systems with tr on PATH outside of /usr/bin.
Message-ID: <20121011204749.746671D41@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8557b412f679f1a9c8edb91e43b35793645c901e
Commit:        8557b412f679f1a9c8edb91e43b35793645c901e
Parent:        413d91dc29a41b44c80df5ff5d054b36895718eb
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 11 22:39:40 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 11 22:40:58 2012 +0200

lvmdump: Fix systems with tr on PATH outside of /usr/bin.

---
 scripts/lvmdump.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 5e764f2..5901892 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -32,6 +32,7 @@ DATE=date
 BASENAME=basename
 UDEVADM=udevadm
 UNAME=uname
+TR=tr
 
 # user may override lvm and dmsetup location by setting LVM_BINARY
 # and DMSETUP_BINARY respectively
@@ -80,7 +81,7 @@ while getopts :acd:hmu opt; do
 	esac
 done
 
-NOW=`$DATE -u +%G%m%d%k%M%S | /usr/bin/tr -d ' '`
+NOW=`$DATE -u +%G%m%d%k%M%S | $TR -d ' '`
 if test -n "$userdir"; then
 	dir="$userdir"
 else


