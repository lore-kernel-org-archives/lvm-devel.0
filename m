From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:24:16 +0000 (UTC)
Subject: master - tests: thin
Message-ID: <20141103132416.1827A60E6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=847b2aa5b418c80d4fe2fb68dec32e7992416ba0
Commit:        847b2aa5b418c80d4fe2fb68dec32e7992416ba0
Parent:        e4e96f6b19e2ae7ba8841c1e93ba385cc18ca3c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 23:18:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

tests: thin

---
 test/shell/lvcreate-thin.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 733888e..0433ac8 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -239,7 +239,9 @@ aux teardown_devs
 aux prepare_pvs 10 16500
 vgcreate $vg -s 64K $(cat DEVICES)
 
-lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
+# Size 0 is not valid
+invalid lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
+lvcreate -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 2>out
 grep "WARNING: Minimum" out
 # FIXME: metadata allocation fails, if PV doesn't have at least 16GB
 # i.e. pool metadata device cannot be multisegment


