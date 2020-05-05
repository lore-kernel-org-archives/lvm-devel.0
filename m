From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue,  5 May 2020 12:16:02 +0000 (GMT)
Subject: master - spec: Enable integrity
Message-ID: <20200505121602.1A32C387086F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=33265467f9c1cf701293fdf8921f6d92eb7d11d9
Commit:        33265467f9c1cf701293fdf8921f6d92eb7d11d9
Parent:        5263551a2d14e52a3f62152616bb8fb9ac8c384c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue May 5 14:12:32 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue May 5 14:12:32 2020 +0200

spec: Enable integrity

---
 spec/source.inc | 1 +
 1 file changed, 1 insertion(+)

diff --git a/spec/source.inc b/spec/source.inc
index 9bb8740f1..d608debab 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -41,6 +41,7 @@
 %with vdo internal
 %with vdo-format %{_bindir}/vdoformat
 %with writecache internal
+%with integrity internal
 
 %global buildreq_udev systemd-devel
 %global req_udev udev >= 181-1



