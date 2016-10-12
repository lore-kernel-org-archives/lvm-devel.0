From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Oct 2016 11:52:20 +0000 (UTC)
Subject: master - spec: move dmeventd -R from post to posttrans script for device-mapper-event package
Message-ID: <20161012115220.32A4360F58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c55c4ac18f60822da6bf61dde9dec3467a9e79a
Commit:        5c55c4ac18f60822da6bf61dde9dec3467a9e79a
Parent:        900e899739b95bcf5a429fc46dd6f16a4b7b50d0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 12 13:50:22 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 12 13:52:13 2016 +0200

spec: move dmeventd -R from post to posttrans script for device-mapper-event package

See also https://bugzilla.redhat.com/show_bug.cgi?id=1382688.
---
 spec/packages.inc |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 41f6ff7..85c9e6d 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -609,9 +609,6 @@ of device-mapper devices.
 %if %{enable_systemd}
 systemctl preset dm-event.socket > /dev/null 2>&1 || :
 %endif
-if [ -e %{_default_pid_dir}/dmeventd.pid ]; then
-        %{_sbindir}/dmeventd -R || echo "Failed to restart dmeventd daemon. Please, try manual restart."
-fi
 
 %preun -n device-mapper-event
 %if %{enable_systemd}
@@ -626,6 +623,11 @@ if [ $1 = 0 ]; then
 %daemon_reload
 fi
 
+%posttrans -n device-mapper-event
+if [ -e %{_default_pid_dir}/dmeventd.pid ]; then
+        %{_sbindir}/dmeventd -R || echo "Failed to restart dmeventd daemon. Please, try manual restart."
+fi
+
 %files -n device-mapper-event
 %defattr(-,root,root,-)
 %{_sbindir}/dmeventd


