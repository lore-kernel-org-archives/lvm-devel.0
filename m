From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 16 Mar 2017 08:05:12 -0400
Subject: master - spec: Update requirements for lockd
Message-ID: <201703161205.v2GC5CY4009060@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ba82a16db75a882b886b124c5f893a0ab636ba6
Commit:        5ba82a16db75a882b886b124c5f893a0ab636ba6
Parent:        cf0bf4b3143209007c98ae9857f4d68488b5b39f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Sep 16 17:21:24 2016 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 16 13:03:24 2017 +0100

spec: Update requirements for lockd

lockd requires sanlock >= 3.3.0
---
 spec/source.inc |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 97f29f1..3fa8038 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -48,9 +48,9 @@
 %global req_udev udev >= 181-1
 
 
-%if %{fedora} >= 22 || %{rhel} >= 7
+%if %{fedora} >= 24 || %{rhel} >= 7
  %service lvmlockd 1
- %define sanlock_version 3.2.4-1
+ %define sanlock_version 3.3.0-1
  %define enable_lockd_dlm 1
  %define enable_lockd_sanlock 1
  %if %{rhel}


