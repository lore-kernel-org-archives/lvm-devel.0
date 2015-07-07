From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue,  7 Jul 2015 15:00:17 +0000 (UTC)
Subject: master - spec: Move lvm2-lockd into separate package
Message-ID: <20150707150017.9D92060066@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9d47b7b88b47719ff972f27a448f9cdf6982c4a
Commit:        d9d47b7b88b47719ff972f27a448f9cdf6982c4a
Parent:        181e701cc51af20c599998358a49902228cb65c1
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 7 16:27:17 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 7 16:53:19 2015 +0200

spec: Move lvm2-lockd into separate package

---
 spec/packages.inc |   52 ++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 40 insertions(+), 12 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index ed02822..33dda2e 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -86,10 +86,6 @@ fi
 %if %{have_service lvmpolld}
  %{_sbindir}/lvmpolld
 %endif
-%if %{have_service lvmlockd}
- %{_sbindir}/lvmlockd
- %{_sbindir}/lvmlockctl
-%endif
 %if %{have_with cache}
   %{_mandir}/man7/lvmcache.7.gz
 %endif
@@ -160,9 +156,6 @@ fi
   %{_mandir}/man8/lvmpolld.8.gz
   %{_mandir}/man8/lvm-lvpoll.8.gz
 %endif
-%if %{have_service lvmlockd}
-  %{_mandir}/man8/lvmlockd.8.gz
-%endif
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
@@ -174,7 +167,6 @@ fi
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive
-%dir %{_default_locking_dir}
 %dir %{_default_run_dir}
 %if %{enable_systemd}
  %config(noreplace) %{_prefix}/lib/tmpfiles.d/%{name}.conf
@@ -189,10 +181,6 @@ fi
   %{_unitdir}/lvm2-lvmpolld.service
   %{_unitdir}/lvm2-lvmpolld.socket
  %endif
- %if %{have_service lvmlockd}
-  %{_unitdir}/lvm2-lvmlockd.service
-  %{_unitdir}/lvm2-lvmlocking.service
- %endif
 %else
  %{_sysconfdir}/rc.d/init.d/lvm2-monitor
  %{_sysconfdir}/rc.d/init.d/blk-availability
@@ -259,6 +247,46 @@ This package contains shared lvm2 libraries for applications.
 %{_libdir}/libdevmapper-event-lvm2snapshot.so
 %{_libdir}/libdevmapper-event-lvm2raid.so
 
+
+##############################################################################
+# LVM locking daemon
+##############################################################################
+%if %{have_service lvmlockd}
+%package lockd
+Summary: LVM locking daemon
+Group: System Environment/Base
+Requires: lvm2 = %{version}-%{release}
+%if %{enable_lockd_dlm}
+Requires: dlm >= %{dlm_version}
+%endif
+%if %{enable_lockd_sanlock}
+Requires: sanlock-lib >= %{sanlock_version}
+%endif
+Requires(post): systemd-units
+Requires(preun): systemd-units
+Requires(postun): systemd-units
+
+%description lockd
+LVM commands use lvmlockd to coordinate access to shared storage.
+
+%post lockd
+%systemd_post lvm2-lvmlockd.service lvm2-lvmlocking.service
+
+%preun lockd
+%systemd_preun lvm2-lvmlockd.service lvm2-lvmlocking.service
+
+%postun lockd
+%systemd_postun lvm2-lvmlockd.service lvm2-lvmlocking.service
+
+%files lockd
+%{_sbindir}/lvmlockd
+%{_sbindir}/lvmlockctl
+%{_mandir}/man8/lvmlockd.8.gz
+%dir %{_default_locking_dir}
+%{_unitdir}/lvm2-lvmlockd.service
+%{_unitdir}/lvm2-lvmlocking.service
+%endif
+
 ##############################################################################
 # Cluster subpackage
 ##############################################################################


