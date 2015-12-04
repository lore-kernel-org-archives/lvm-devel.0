From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  4 Dec 2015 21:11:41 +0000 (UTC)
Subject: master - debug: correct stack tracing
Message-ID: <20151204211141.3A53960515@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b16efd17c8341af719a407aafa010c3c3ad3353
Commit:        8b16efd17c8341af719a407aafa010c3c3ad3353
Parent:        45781161f49dcd9b31909ec40766ab4e71d0afa0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 4 22:02:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 4 22:10:30 2015 +0100

debug: correct stack tracing

Here the 'goto' is correct path, as  !device_is_usable
is traceable with <backtrace>.

Keep the 'stack' for unusable device.
---
 lib/activate/dev_manager.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4d0b4d8..588031d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -321,7 +321,8 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 					       .check_suspended = ignore_suspended_devices(),
 					       .check_error_target = 1,
 					       .check_reserved = 0 }))
-				goto_out;
+				goto out; /* safe to use */
+			stack;
 		}
 	}
 


