From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Apr 2014 12:59:53 +0000 (UTC)
Subject: master - systemd: make sysinit.target to pull in lvm2-lvmetad.socket, not sockets.target
Message-ID: <20140430125954.0101D6053F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81b096af34283cf91205b0e63f598ca92d625051
Commit:        81b096af34283cf91205b0e63f598ca92d625051
Parent:        4e559103d51e02c0d64d9cf88cee11d762feb65e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 30 14:52:10 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 30 14:52:10 2014 +0200

systemd: make sysinit.target to pull in lvm2-lvmetad.socket, not sockets.target

The sysinit.target is ordered even before sockets.target and there
may be situations in which the lvmetad is needed early, for example
in rescue.target to activate some LVs on which mountpoints reside.
Also, like in the case of rescue.target, the sockets.target is not
pulled in (unless some other service pulls it in explicitly).

See also: https://bugzilla.redhat.com/show_bug.cgi?id=1087586#c26
for the summary of the problem.
---
 scripts/lvm2_lvmetad_systemd_red_hat.socket.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
index 9a46f50..071fd64 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
@@ -8,4 +8,4 @@ ListenStream=@DEFAULT_RUN_DIR@/lvmetad.socket
 SocketMode=0600
 
 [Install]
-WantedBy=sockets.target
+WantedBy=sysinit.target


