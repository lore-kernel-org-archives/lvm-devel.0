From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 16 Mar 2017 08:05:24 -0400
Subject: master - spec: Disable sanlock only, keep lockd_dlm enabled
Message-ID: <201703161205.v2GC5Oxd009092@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a87715b6fdd4e95be425ef629c5247ecf1ef169e
Commit:        a87715b6fdd4e95be425ef629c5247ecf1ef169e
Parent:        19b65a3d76e8e316a11c59a690b82bff3203566c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Sep 16 18:01:31 2016 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 16 13:03:25 2017 +0100

spec: Disable sanlock only, keep lockd_dlm enabled

---
 spec/source.inc |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 43bb20c..30a706c 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -65,6 +65,11 @@
    %global enable_lockd_sanlock 0
   %endif
  %endif
+%else
+ %if %{fedora} >= 22
+  %service lvmlockd 1
+  %global enable_lockd_dlm 1
+ %endif
 %endif
 
 ##############################################################


