From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:34 +0000 (UTC)
Subject: master - NIX: Add %with thin_dump to the specfile.
Message-ID: <20140228102534.92A0B60F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f60d53fccfa5224a61ec4ef21bce1004f1142b9
Commit:        5f60d53fccfa5224a61ec4ef21bce1004f1142b9
Parent:        bf67c0b393ca08f909180994f1e03690c3fbdfe1
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Aug 30 18:30:20 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Add %with thin_dump to the specfile.

---
 spec/source.inc |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 1cbd8bf..3da93ee 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -16,6 +16,7 @@
 %with thin internal
 %with thin_check %{_sbindir}/thin_check
 %with thin_repair %{_sbindir}/thin_repair
+%with thin_dump %{_sbindir}/thin_dump
 
 %global buildreq_udev systemd-devel
 %global req_udev udev >= 181-1
@@ -35,6 +36,7 @@
 %with thin
 %with thin_check
 %with thin_repair
+%with thin_dump
 %endif
 
 ##############################################################


