From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 21 Mar 2016 22:33:57 +0000 (UTC)
Subject: master - lvmdbusd: Remove --udev in service file
Message-ID: <20160321223357.D220F6072A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86e9d12b6f06c741ada66cd417f3fa82ea0364b6
Commit:        86e9d12b6f06c741ada66cd417f3fa82ea0364b6
Parent:        cc57cd39ab0e47a3e0fc6fc81c378c4d4d292093
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Mar 21 10:18:18 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 21 17:28:51 2016 -0500

lvmdbusd: Remove --udev in service file

With commit 2d5dc6512e10924ab68e6a139081d7121bc3f7d6 the dbus server
no longer needs to utilize udev to know when to update its internal
state.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 scripts/lvm2_lvmdbusd_systemd_red_hat.service.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
index d3ad870..64cec4e 100644
--- a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
@@ -5,7 +5,7 @@ Documentation=man:lvmdbusd(8)
 [Service]
 Type=dbus
 BusName=com.redhat.lvmdbus1
-ExecStart=@sbindir@/lvmdbusd --udev
+ExecStart=@sbindir@/lvmdbusd
 
 [Install]
 WantedBy=multi-user.target


