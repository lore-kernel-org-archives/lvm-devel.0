From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Sep 2019 04:52:34 -0400
Subject: stable-2.02 - build: make generate
Message-ID: <201909240852.x8O8qYdI006887@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=444dedea2355b42000f60b4ca0eb4a2f027123aa
Commit:        444dedea2355b42000f60b4ca0eb4a2f027123aa
Parent:        92f1c888e0881f3defb4d0220d89f6225be70f7d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Sep 24 10:38:22 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Sep 24 10:38:22 2019 +0200

build: make generate

---
 man/lvchange.8_pregen |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 26a6297..5c3b6e5 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -340,7 +340,9 @@ required, after which the others are optional.
 .br
 -
 
-Resyncronize a mirror or raid LV.
+Resyncronize a mirror or raid LV. 
+.br
+Use to reset 'R' attribute on a not initially synchronized LV.
 .br
 .P
 \fBlvchange\fP \fB--resync\fP \fIVG\fP|\fILV\fP\fI_mirror_raid\fP|\fITag\fP|\fISelect\fP ...


