From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 08:53:54 +0000 (UTC)
Subject: master - tests: respect @CONFDIR@/machine-id
Message-ID: <20150514085354.5DF8D601FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a42c1c5728d28b8903725694afb3735dac62f11a
Commit:        a42c1c5728d28b8903725694afb3735dac62f11a
Parent:        57a16abe2ce75f65306b70a4dd8e1cd45cbe385d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 10:51:34 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 10:52:55 2015 +0200

tests: respect @CONFDIR@/machine-id

Obtain location of machine-id.

NOTE: lvmconfig cannot dump 'life' value - should be fixed.
---
 test/shell/system_id.sh |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 3e3fa94..5bb5c3a 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -47,10 +47,12 @@ vgcreate $vg1 "$dev1"
 check vg_field $vg1 systemid $SID
 vgremove $vg1
 
-## machineid
+# FIXME - print 'life' config data
+eval $(lvmconfig global/etc 2>/dev/null || lvmconfig --type default global/etc)
 
-if [ -e /etc/machine-id ]; then
-SID=$(cat /etc/machine-id)
+## machineid
+if [ -e $etc/machine-id ]; then
+SID=$(cat $etc/machine-id)
 aux lvmconf "global/system_id_source = machineid"
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
@@ -608,8 +610,8 @@ rm -f $SIDFILE
 # The commands should proceed without a system_id.
 # Look at the warning/error messages.
 
-# vgcreate with source machineid, where no /etc/machine-id file exists
-if [ ! -e /etc/machine-id ]; then
+# vgcreate with source machineid, where no $etc/machine-id file exists
+if [ ! -e $etc/machine-id ]; then
 SID=""
 aux lvmconf "global/system_id_source = machineid"
 vgcreate $vg1 "$dev1" 2>&1 | tee err


