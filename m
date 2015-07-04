From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Sat,  4 Jul 2015 12:38:51 +0000 (UTC)
Subject: master - Build lockd only for Fedora >= 22 and RHEL >= 7
Message-ID: <20150704123851.5AE7C614A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd385eb5ac963c74b617b912c99ef97e4a73486f
Commit:        dd385eb5ac963c74b617b912c99ef97e4a73486f
Parent:        b4e8de3a3156e2385e08bf12fb483eb3cad519e2
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jun 26 19:03:56 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Sat Jul 4 14:36:57 2015 +0200

Build lockd only for Fedora >= 22 and RHEL >= 7

---
 spec/source.inc |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 00d5282..0a0d9e5 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -27,7 +27,9 @@
 
 %service lvmpolld 1
 
+%if %{fedora} >= 22 || %{rhel} >= 7
 %service lvmlockd 1
+%endif
 
 ##############################################################
 


