From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:21:24 +0000 (UTC)
Subject: master - man: missing (C)ache in target type lv_attr description
Message-ID: <20140815132124.E05E5610B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d213758e5720f47d3a5781d958431c8d80afdda7
Commit:        d213758e5720f47d3a5781d958431c8d80afdda7
Parent:        9534c21ead16dae8975fdaf1959b5534dc175f84
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 15 15:21:15 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 15 15:21:15 2014 +0200

man: missing (C)ache in target type lv_attr description

---
 man/lvs.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index 3ab4120..f268584 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -169,7 +169,7 @@ mapped (d)evice present without tables, mapped device present with (i)nactive ta
 .IP 6 3
 device (o)pen, (X) unknown
 .IP 7 3
-Target type: (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.
+Target type: (C)ache, (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.
 This groups logical volumes related to the same kernel target together.  So,
 for example, mirror images, mirror logs as well as mirrors themselves appear as
 (m) if they use the original device-mapper mirror kernel driver; whereas the raid


