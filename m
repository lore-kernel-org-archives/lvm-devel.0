From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Sat,  4 Jul 2015 12:38:53 +0000 (UTC)
Subject: master - lockd: Clean up spec
Message-ID: <20150704123853.82BA261255@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5fb71bd53062011dd962d77b233552ffad128238
Commit:        5fb71bd53062011dd962d77b233552ffad128238
Parent:        dd385eb5ac963c74b617b912c99ef97e4a73486f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jul 3 09:46:49 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Sat Jul 4 14:36:57 2015 +0200

lockd: Clean up spec

---
 nix/default.nix   |    2 +-
 spec/packages.inc |    4 ----
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index c7462a0..abfbcd9 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -367,7 +367,7 @@ let
       centos66 = centos65;
       centos70 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
                    "socat" # used by test suite lvmpolld
-                   "sanlock" # used by test suite lvmlockd
+                   # "sanlock" # used by lvmlockd. Required version present in 7.2 only
                    "procps-ng" ];
 
       fedora17_18 = [ "dlm-devel" "corosynclib-devel" "libblkid" "libblkid-devel"
diff --git a/spec/packages.inc b/spec/packages.inc
index 8d2195a..ed02822 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -192,7 +192,6 @@ fi
  %if %{have_service lvmlockd}
   %{_unitdir}/lvm2-lvmlockd.service
   %{_unitdir}/lvm2-lvmlocking.service
-  #%{_unitdir}/lvm2-lvmlockd.socket
  %endif
 %else
  %{_sysconfdir}/rc.d/init.d/lvm2-monitor
@@ -203,9 +202,6 @@ fi
  %if %{have_service lvmpolld}
   %{_sysconfdir}/rc.d/init.d/lvm2-lvmpolld
  %endif
- #%if %{have_service lvmlockd}
- # %{_sysconfdir}/rc.d/init.d/lvm2-lvmlockd
- #%endif
 %endif
 
 ##############################################################################


