From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue,  9 Aug 2022 14:18:04 +0000 (GMT)
Subject: main - spec: use --with-default-use-devices-file=1 for rhel9+
Message-ID: <20220809141804.746653856DC2@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e6ed2c458a47b2ea4b43c4e0b00ec070040a592
Commit:        4e6ed2c458a47b2ea4b43c4e0b00ec070040a592
Parent:        31f9c4bfab4d859369b0a5365fda44e398a4656b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Aug 9 16:02:39 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 9 16:17:43 2022 +0200

spec: use --with-default-use-devices-file=1 for rhel9+

---
 spec/source.inc | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/spec/source.inc b/spec/source.inc
index 3e7573025..7b44ef152 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -121,6 +121,10 @@
 %with thin_dump
 %endif
 
+%if %{rhel} >= 9
+%with default-use-devices-file 1
+%endif
+
 ##############################################################
 
 %if %{fedora} == 17

