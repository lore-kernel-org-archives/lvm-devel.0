From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 20:25:26 +0000 (UTC)
Subject: master - man: lvs lv_attr 's(k)ip activation'
Message-ID: <20130712202526.A1C3C6137E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdd2246ce91d8b8c050ad7a2b52e32489262c4b3
Commit:        bdd2246ce91d8b8c050ad7a2b52e32489262c4b3
Parent:        9a44ba94a5ab54aaad9fdc6c2e1d1eb4587fd651
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 12 22:24:26 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 12 22:24:26 2013 +0200

man: lvs lv_attr 's(k)ip activation'

---
 man/lvs.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index a020bf7..5df6b47 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -177,7 +177,7 @@ are found.  ("check" and "repair" of a RAID Logical Volume can be done via
 the 'lvchange' command.)  (w)ritemostly signifies the devices in a RAID 1
 logical volume that have been marked write-mostly.
 .IP 10 3
-(n)o activation: this volume is flagged to be skipped during activation.
+s(k)ip activation: this volume is flagged to be skipped during activation.
 .RE
 .TP
 .BR \-O ", " \-\-sort


