From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:10 +0000 (GMT)
Subject: main - tests: raise required version for conversion
Message-ID: <20210921195110.ADC643858C3A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4cfa80f02f769f723fad37d3e1d8697a106ee603
Commit:        4cfa80f02f769f723fad37d3e1d8697a106ee603
Parent:        b0d40109a67a99bf568c168a31f37955a07d7da4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 21:43:02 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:43:02 2021 +0200

tests: raise required version for conversion

Real conversion needs this version driver.
TODO: handle properly older versions.
---
 test/shell/vdo-convert.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index f82529a2d..2a2026c2e 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -40,6 +40,11 @@ aux prepare_devs 2 10000
 aux extend_filter_LVMTEST
 
 
+
+
+# Conversion can be made with this version of vdo driver
+aux have_vdo 6 2 5 || skip
+
 #
 #  Check conversion of VDO volume made on some LV
 #


