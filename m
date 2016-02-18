From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 18 Feb 2016 11:38:01 +0000 (UTC)
Subject: master - Fix rpm builds
Message-ID: <20160218113801.8FB1860DAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef5583a209f5ec1ac0d950705f79c4d948050439
Commit:        ef5583a209f5ec1ac0d950705f79c4d948050439
Parent:        bc19a16fc7d952550849b1f6359ed0515515f0aa
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Feb 18 12:36:43 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Feb 18 12:37:44 2016 +0100

Fix rpm builds

---
 spec/build.inc |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index bc57436..2bb285d 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -30,7 +30,7 @@
 %enableif %{enable_lockd_dlm} lockd-dlm
 %enableif %{enable_lockd_sanlock} lockd-sanlock
 %endif
-%enableif %{enable_python} python-bindings
+%enableif %{enable_python} python2-bindings
 %enableif %{enable_python} applib
 
 %build
@@ -39,7 +39,7 @@
 rm -rf %{py3dir}
 cp -a . %{py3dir}
 pushd %{py3dir}
-%configure %{configure_flags} PYTHON=/usr/bin/python3 PYTHON_CONFIG=/usr/bin/python3-config
+%configure %{configure_flags} --disable-python2-bindings --enable-python3-bindings PYTHON=/usr/bin/python3 PYTHON_CONFIG=/usr/bin/python3-config
 
 make %{?_smp_mflags}
 popd


