From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 22 Oct 2018 06:54:12 -0400
Subject: master - spec: lvmdbusd requires python3 setuptools
Message-ID: <201810221054.w9MAsCIr027245@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc35a9169e9f5804e38e4a6a6a7bf3555c49b636
Commit:        fc35a9169e9f5804e38e4a6a6a7bf3555c49b636
Parent:        7498f8383397a93db95655ca227257836cbcac82
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 22 12:51:51 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Oct 22 12:51:51 2018 +0200

spec: lvmdbusd requires python3 setuptools

---
 spec/source.inc |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 4561e8a..8309c3f 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -82,7 +82,7 @@
 
 %if %{enable_dbusd}
   %global buildreq_python3_devel python3-devel
-  %global buildreq_python_setuptools python-setuptools
+  %global buildreq_python3_setuptools python3-setuptools
   %global buildreq_python3_dbus python3-dbus
   %global buildreq_python3_pyudev python3-pyudev
 %endif
@@ -168,7 +168,7 @@ BuildRequires: pkgconfig
 %maybe BuildRequires: %{?buildreq_lvmlockd_dlm}
 %maybe BuildRequires: %{?buildreq_lvmlockd_sanlock}
 %maybe BuildRequires: %{?buildreq_python3_devel}
-%maybe BuildRequires: %{?buildreq_python_setuptools}
+%maybe BuildRequires: %{?buildreq_python3_setuptools}
 
 %description
 LVM2 includes all of the support for handling read/write operations on


