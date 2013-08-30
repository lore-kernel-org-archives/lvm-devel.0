From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 30 Aug 2013 16:54:16 +0000 (UTC)
Subject: master - test: fix process-each-duplicate-vgnames
Message-ID: <20130830165416.6BCE461192@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eee3aeeb612c65c0851bf8080e0ef381587837ab
Commit:        eee3aeeb612c65c0851bf8080e0ef381587837ab
Parent:        c36dcc17282cf9c5f745cc627f9ce3825b4ee5e2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 30 11:45:12 2013 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 30 11:53:10 2013 -0500

test: fix process-each-duplicate-vgnames

After enable_dev, the following commands were not
consistently seeing the pv on it.

Alasdair explained, "whenever enabling/disabling devs
outside the tools (and you aren't trying to test how
the tools cope with suddenly appearing/disappering
devices) use "vgscan""
---
 test/shell/process-each-duplicate-vgnames.sh |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 865ef9f..6eeaa6f 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -18,15 +18,22 @@ aux disable_dev $dev1
 aux disable_dev $dev2
 
 aux enable_dev $dev1
+vgscan
 vgcreate $vg1 $dev1
 UUID1=$(vgs --noheading -o vg_uuid $vg1)
 aux disable_dev $dev1
 
 aux enable_dev $dev2
+vgscan
 vgcreate $vg1 $dev2
 UUID2=$(vgs --noheading -o vg_uuid $vg1)
 
 aux enable_dev $dev1
+# need vgscan after enabling/disabling devs
+# so that the next commands properly see them
+vgscan
+pvs $dev1
+pvs $dev2
 
 vgs -o+vg_uuid >err
 cat err
@@ -43,6 +50,7 @@ cat err
 grep $UUID1 err
 not grep $UUID2 err
 aux enable_dev $dev2
+vgscan
 
 aux disable_dev $dev1
 vgs -o+vg_uuid >err
@@ -50,4 +58,5 @@ cat err
 grep $UUID2 err
 not grep $UUID1 err
 aux enable_dev $dev1
+vgscan
 


