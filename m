From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 25 Sep 2019 02:40:54 -0400
Subject: master - spec: enable writecache
Message-ID: <201909250640.x8P6esBj012437@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90fe4b106b1e13a2d1244951710d642761f2fd16
Commit:        90fe4b106b1e13a2d1244951710d642761f2fd16
Parent:        dc3f0e067d2f402853551142bc917dc9c070d499
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Sep 25 08:39:56 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 25 08:40:30 2019 +0200

spec: enable writecache

---
 spec/source.inc |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 8309c3f..9bb8740 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -37,8 +37,10 @@
 %with thin_check %{_sbindir}/thin_check
 %with thin_repair %{_sbindir}/thin_repair
 %with thin_dump %{_sbindir}/thin_dump
+# TODO disable vdo and writecache for older releases
 %with vdo internal
 %with vdo-format %{_bindir}/vdoformat
+%with writecache internal
 
 %global buildreq_udev systemd-devel
 %global req_udev udev >= 181-1


