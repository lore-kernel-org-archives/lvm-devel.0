From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 20 Feb 2009 09:27:44 -0500
Subject: [PATCH] Update symlink for lvm2.h -> lvm.h
In-Reply-To: <1235138029-5804-1-git-send-email-twoerner@redhat.com>
References: <1235138029-5804-1-git-send-email-twoerner@redhat.com>
Message-ID: <1235140064-18914-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/.symlinks b/include/.symlinks
index 1a4bd93..dd07078 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -1,6 +1,6 @@
 ../daemons/clvmd/clvm.h
 ../daemons/dmeventd/libdevmapper-event.h
-../lib/lvm2.h
+../lib/lvm.h
 ../lib/activate/activate.h
 ../lib/activate/targets.h
 ../lib/cache/lvmcache.h
-- 
1.6.0.6


