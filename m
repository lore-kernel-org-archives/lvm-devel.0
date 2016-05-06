From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:01:05 +0000 (UTC)
Subject: master - test: lvmetad-ambiguous
Message-ID: <20160506140105.59C4060722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29a8012724071fb07b72ef7ba2abd4e17d324a4c
Commit:        29a8012724071fb07b72ef7ba2abd4e17d324a4c
Parent:        d4d1d5ac3ebc88f48e7d959cff9ab9c59ba92ba0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 22 16:11:01 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

test: lvmetad-ambiguous

update for duplicate changes
---
 test/shell/lvmetad-ambiguous.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
index ffcbdd3..52f2928 100644
--- a/test/shell/lvmetad-ambiguous.sh
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -26,11 +26,11 @@ dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv1 ${PREFIX}pv1.table
 aux finish_udev_transaction
 
 # re-scan them
-pvscan --cache "$dev1"
-pvscan --cache "$dev2"
+pvscan --cache "$dev1" || true
+pvscan --cache "$dev2" || true
 
 # expect both to be there
-pvs | tee pvs.txt
-grep "$dev1" pvs.txt
-grep "$dev2" pvs.txt
+pvs -a -o name | tee out
+grep "$dev1" out
+grep "$dev2" out
 


