From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  5 Oct 2016 20:57:35 +0000 (UTC)
Subject: master - lvmdbusd: Add LvCommon.DataPercent
Message-ID: <20161005205735.527CD60DD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8bb8dfb08d38cfda5493ca9d35d1cb3bf2d32bf
Commit:        a8bb8dfb08d38cfda5493ca9d35d1cb3bf2d32bf
Parent:        d54ffcfcd12981a8e046aca0a82d529221015b30
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 5 15:51:48 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 5 15:55:41 2016 -0500

lvmdbusd: Add LvCommon.DataPercent

---
 daemons/lvmdbusd/lv.py |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index c2312b7..c356799 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -232,6 +232,7 @@ class LvState(State):
 @utils.dbus_property(LV_COMMON_INTERFACE, 'Attr', 's')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'DataPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'SnapPercent', 'u')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'DataPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'MetaDataPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'CopyPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'SyncPercent', 'u')


