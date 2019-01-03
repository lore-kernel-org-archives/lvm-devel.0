From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 3 Jan 2019 08:40:27 -0500
Subject: 2018-06-01-stable - spec: Use python3 setuptools with python3
Message-ID: <201901031340.x03DeRBs030253@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1d2de5dd130b0db81502ad5fce12f1ab148ede3e
Commit:        1d2de5dd130b0db81502ad5fce12f1ab148ede3e
Parent:        df0797db8cec82df92fb1df2bace184f5a811924
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jan 3 14:39:28 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jan 3 14:39:28 2019 +0100

spec: Use python3 setuptools with python3

---
 spec/source.inc |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 93f9c7b..96c37f1 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -98,7 +98,7 @@
 
 %if %{enable_python3} || %{enable_dbusd}
   %global buildreq_python3_devel python3-devel
-  %global buildreq_python_setuptools python-setuptools
+  %global buildreq_python_setuptools python3-setuptools
 %endif
 
 ##############################################################


