From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 Mar 2015 15:58:12 +0000 (UTC)
Subject: master - tests: fix systemid uname test
Message-ID: <20150306155812.1EB2461141@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08371a8b8031b43394d80612d24029cfd4c710d4
Commit:        08371a8b8031b43394d80612d24029cfd4c710d4
Parent:        588b3bd7a16b19423f9c4d06b27a3cbe7ac9d623
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 6 09:55:24 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 6 09:57:37 2015 -0600

tests: fix systemid uname test

The string reported by uname -n may include characters
that lvm omits from the system id (like parens, as seen
on a test machine.)  Check against the final system id
string that lvm uses.
---
 test/shell/system_id.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 6e80c1a..6aa367b 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -38,12 +38,13 @@ fi
 
 ## uname
 
-SID=$(uname -n)
-if [ -n $SID ]; then
+SID1=$(uname -n)
+if [ -n $SID1 ]; then
 aux lvmconf "global/system_id_source = uname"
+SID2=$(lvm systemid | awk '{ print $3 }')
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID
+check vg_field $vg1 systemid $SID2
 vgremove $vg1
 fi
 


