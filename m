From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 25 Jan 2018 09:39:31 -0500
Subject: master - lvmdbusd: Remove duplicated DataPercent definition
Message-ID: <201801251439.w0PEdVOM032479@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=34fb5202bdb3172a44fb3d957e184df4fb0412d8
Commit:        34fb5202bdb3172a44fb3d957e184df4fb0412d8
Parent:        edb209776f9fec2ce2c0630560e238056c47c978
Author:        Tim Foerster <tim.foerster@hetzner.de>
AuthorDate:    Fri Dec 22 13:33:53 2017 +0100
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jan 25 08:37:24 2018 -0600

lvmdbusd: Remove duplicated DataPercent definition

---
 daemons/lvmdbusd/lv.py |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 6c93e4d..d73d3d2 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -232,7 +232,6 @@ class LvState(State):
 @utils.dbus_property(LV_COMMON_INTERFACE, 'Attr', 's')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'DataPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'SnapPercent', 'u')
- at utils.dbus_property(LV_COMMON_INTERFACE, 'DataPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'MetaDataPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'CopyPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'SyncPercent', 'u')


