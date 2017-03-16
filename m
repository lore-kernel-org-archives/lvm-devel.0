From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 16 Mar 2017 08:05:23 -0400
Subject: master - spec: Replace remaining %define by %global
Message-ID: <201703161205.v2GC5NsM009086@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19b65a3d76e8e316a11c59a690b82bff3203566c
Commit:        19b65a3d76e8e316a11c59a690b82bff3203566c
Parent:        7067514c9b3e5af88629799a4bd60614ef776a9d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Sep 16 17:30:01 2016 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 16 13:03:24 2017 +0100

spec: Replace remaining %define by %global

---
 spec/lvm2.spec  |    2 +-
 spec/macros.inc |   94 +++++++++++++++++++++++++++---------------------------
 2 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/spec/lvm2.spec b/spec/lvm2.spec
index c6373bc..18b1821 100644
--- a/spec/lvm2.spec
+++ b/spec/lvm2.spec
@@ -14,7 +14,7 @@
 # on those systems.
 
 # A macro to pull in an include file from an appropriate location.
-%define import() %include %(test -e %{S:%1} && echo %{S:%1} || echo %{_sourcedir}/%1)
+%global import() %%include %%(test -e %%{S:%%1} && echo %%{S:%%1} || echo %%{_sourcedir}/%%1)
 
 %import source.inc
 
diff --git a/spec/macros.inc b/spec/macros.inc
index 4c4e66b..99ee9a0 100644
--- a/spec/macros.inc
+++ b/spec/macros.inc
@@ -14,70 +14,70 @@
 %global rhel 0
 %endif
 
-%define enableif() \
-%global configure_flags %{?configure_flags} --%(if test %1 -gt 0; then echo enable-%2; else echo disable-%2; fi)
+%global enableif() \
+%%global configure_flags %%{?configure_flags} --%%(if test %%1 -gt 0; then echo enable-%%2; else echo disable-%%2; fi)
 
-%define with() \
-%global configure_flags %(echo -n "%{?configure_flags} " | sed -e "s,--with-%1=[^ ]*,,"; test -n "%{?2}" && echo --with-%1=%2) \
-%global with_flags %(echo -n "%{?with_flags} " | sed -e "s,%1,,"; test -n "%{?2}" && test "%{?2}" != none && echo %1)
+%global with() \
+%%global configure_flags %%(echo -n "%%{?configure_flags} " | sed -e "s,--with-%%1=[^ ]*,,"; test -n "%%{?2}" && echo --with-%%1=%%2) \
+%%global with_flags %%(echo -n "%%{?with_flags} " | sed -e "s,%%1,,"; test -n "%%{?2}" && test "%%{?2}" != none && echo %%1)
 
 %global services monitor
-%define service() \
-%global services %(echo -n "%{?services} " | sed -e s,%1,,; test "%2" = 1 && echo %1)
+%global service() \
+%%global services %%(echo -n "%%{?services} " | sed -e s,%%1,,; test "%%2" = 1 && echo %%1)
 
-%define maybe() \
-%if %(test -n "%{?2}" && echo 1 || echo 0) \
-%* \
-%endif
+%global maybe() \
+%%if %%(test -n "%%{?2}" && echo 1 || echo 0) \
+%%* \
+%%endif
 
-%define have_with() %(if echo %{with_flags} | grep -q %1; then echo 1; else echo 0; fi)
-%define have_service() %(if echo %{services} | grep -q %1; then echo 1; else echo 0; fi)
+%global have_with() %%(if echo %%{with_flags} | grep -q %%1; then echo 1; else echo 0; fi)
+%global have_service() %%(if echo %%{services} | grep -q %%1; then echo 1; else echo 0; fi)
 
-%define daemon_reload \
-%if %{enable_systemd} \
+%global daemon_reload \
+%%if %%{enable_systemd} \
 systemctl daemon-reload > /dev/null 2>&1 || : \
-%endif \
+%%endif \
 : \
-%{nil}
+%%{nil}
 
-%define enable(s:t:) \
-%if %{have_service %{-s*}} \
-%if %{enable_systemd} \
+%global enable(s:t:) \
+%%if %%{have_service %%{-s*}} \
+%%if %%{enable_systemd} \
 if [ $1 = 1 ]; then \
-	systemctl preset lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+	systemctl preset lvm2-%%{-s*}.%%{-t*} > /dev/null 2>&1 || : \
 fi \
-%else \
-/sbin/chkconfig --add lvm2-%{-s*} \
-%endif \
-%endif \
+%%else \
+/sbin/chkconfig --add lvm2-%%{-s*} \
+%%endif \
+%%endif \
 : \
-%{nil}
+%%{nil}
 
-%define disable(s:t:) \
-%if %{have_service %{-s*}} \
-%if %{enable_systemd} \
+%global disable(s:t:) \
+%%if %%{have_service %%{-s*}} \
+%%if %%{enable_systemd} \
 if [ $1 = 0 ]; then \
-	systemctl --no-reload disable lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
-	%if %{-t*} == socket \
-	systemctl --no-reload disable lvm2-%{-s*}.service > /dev/null 2>&1 || : \
-	%endif \
-	systemctl stop lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
-	%if %{-t*} == socket \
-	systemctl stop lvm2-%{-s*}.service > /dev/null 2>&1 || : \
-	%endif \
+	systemctl --no-reload disable lvm2-%%{-s*}.%%{-t*} > /dev/null 2>&1 || : \
+	%%if %%{-t*} == socket \
+	systemctl --no-reload disable lvm2-%%{-s*}.service > /dev/null 2>&1 || : \
+	%%endif \
+	systemctl stop lvm2-%%{-s*}.%%{-t*} > /dev/null 2>&1 || : \
+	%%if %%{-t*} == socket \
+	systemctl stop lvm2-%%{-s*}.service > /dev/null 2>&1 || : \
+	%%endif \
 fi \
-%else \
-/sbin/chkconfig --del lvm2-%{-s*} \
-%endif \
-%endif \
+%%else \
+/sbin/chkconfig --del lvm2-%%{-s*} \
+%%endif \
+%%endif \
 : \
-%{nil}
+%%{nil}
 
-%define try_restart(s:t:) \
-%if %{have_service %{-s*}} && %{enable_systemd} \
+%global try_restart(s:t:) \
+%%if %%{have_service %%{-s*}} && %%{enable_systemd} \
 if [ $1 = 1 ]; then \
-	systemctl try-restart lvm2-%{-s*}.%{-t*} > /dev/null 2>&1 || : \
+	systemctl try-restart lvm2-%%{-s*}.%%{-t*} > /dev/null 2>&1 || : \
 fi \
-%endif \
+%%endif \
 : \
-%{nil}
+%%{nil}


