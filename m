From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:54:05 +0000 (UTC)
Subject: master - spec: configurable cache build
Message-ID: <20140520195405.B934860C83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e538354e281c7b00667b3385878b4c32693359b5
Commit:        e538354e281c7b00667b3385878b4c32693359b5
Parent:        08fd24450685abd935d744795a6c2fc5e819ef64
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 19:56:20 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:30 2014 +0200

spec: configurable cache build

Install lvmcache man page when being configured with cache support.
Install lvmthin man page only with thin support.
---
 spec/packages.inc |    8 ++++++--
 spec/source.inc   |    2 ++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 5999ab7..e70f6ad 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -82,9 +82,13 @@ fi
 %if %{have_service lvmetad}
  %{_sbindir}/lvmetad
 %endif
+%if %{have_with cache}
+  %{_mandir}/man7/lvmcache.7.gz
+%endif
+%if %{have_with thin}
+  %{_mandir}/man7/lvmthin.7.gz
+%endif
 %{_mandir}/man5/lvm.conf.5.gz
-%{_mandir}/man7/lvmcache.7.gz
-%{_mandir}/man7/lvmthin.7.gz
 %{_mandir}/man8/fsadm.8.gz
 %{_mandir}/man8/lvchange.8.gz
 %{_mandir}/man8/lvconvert.8.gz
diff --git a/spec/source.inc b/spec/source.inc
index 0a1c270..6ef4791 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -13,6 +13,7 @@
 %with clvmd corosync
 
 # TODO %global req_dm_persistent device-mapper-persistent-data >= 0.1.4
+%with cache internal
 %with thin internal
 %with thin_check %{_sbindir}/thin_check
 %with thin_repair %{_sbindir}/thin_repair
@@ -39,6 +40,7 @@
 %endif
 
 %if %{fedora} == 16
+%with cache none
 %with thin none
 %with thin_check
 %with thin_repair


