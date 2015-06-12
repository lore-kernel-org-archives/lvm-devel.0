From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Jun 2015 15:10:24 +0000 (UTC)
Subject: master - test: Ensure that outdated PVs are wiped just once.
Message-ID: <20150612151024.BC1DB60AAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c0049b1ce027ab4befdbfbcd8194d57ce6eb2b7
Commit:        9c0049b1ce027ab4befdbfbcd8194d57ce6eb2b7
Parent:        632dde0cbc98de9c04b4c2451d09e36d6299bbd6
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jun 10 16:27:59 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 10 16:27:59 2015 +0200

test: Ensure that outdated PVs are wiped just once.

---
 test/shell/unlost-pv.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index 09de21a..c56d488 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -45,4 +45,10 @@ check_
 test -e LOCAL_LVMETAD && lvremove $vg/boo # FIXME trigger a write :-(
 check_ not
 
+aux disable_dev "$dev1"
+vgreduce --removemissing --force $vg
+aux enable_dev "$dev1"
+vgs 2>&1 | grep 'Removing PV'
+vgs 2>&1 | not grep 'Removing PV'
+
 vgremove -ff $vg


