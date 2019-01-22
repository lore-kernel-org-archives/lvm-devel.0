From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Jan 2019 08:36:32 -0500
Subject: master - rpm: package lvmvdo man page
Message-ID: <201901221336.x0MDaWhM032603@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a45ef030060a28fa152f6245828a97df04c195c
Commit:        2a45ef030060a28fa152f6245828a97df04c195c
Parent:        2264399b0df9a5f81449fcabca891557a2df4026
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 22 14:33:03 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 22 14:35:47 2019 +0100

rpm: package lvmvdo man page

---
 spec/packages.inc |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 81ef539..196cbf6 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -148,6 +148,9 @@ fi
   %{_mandir}/man8/lvmpolld.8.gz
   %{_mandir}/man8/lvm-lvpoll.8.gz
 %endif
+%if %{have_with vdo}
+  %{_mandir}/man7/lvmvdo.7.gz
+%endif
 %if %{enable_udev}
  %{_udevdir}/11-dm-lvm.rules
  %{_udevdir}/69-dm-lvm-metad.rules


