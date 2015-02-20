From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 20 Feb 2015 19:14:22 +0000 (UTC)
Subject: master - tests: skip system_id machineid case when not available
Message-ID: <20150220191422.E0FC3610A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55dd45239a52a7349f8a2380b3e29dc3beee39f5
Commit:        55dd45239a52a7349f8a2380b3e29dc3beee39f5
Parent:        e0946dca69d631106c99edcef1221af78819e2c0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 20 13:12:38 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 20 13:12:38 2015 -0600

tests: skip system_id machineid case when not available

instead of creating a fake /etc/machine-id file on the
system to test with.
---
 test/shell/system_id.sh |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 71e6ee9..98924b0 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -27,16 +27,14 @@ vgremove $vg1
 
 ## machineid
 
-if [ ! -e /etc/machine-id ]; then
-  echo "49e0eef929d541a0b8b56128441b2d60" > /etc/machine-id
-fi
+if [ -e /etc/machine-id ]; then
 SID=$(cat /etc/machine-id)
 aux lvmconf "global/system_id_source = machineid"
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 vgremove $vg1
-# FIXME: remove file if created
+fi
 
 ## uname
 


