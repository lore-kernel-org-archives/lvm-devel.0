From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:37:36 +0200
Subject: [PATCH 1/2] Fix report of leak of _mem_pool in lvm2_exit()
In-Reply-To: <cover.1281256324.git.zkabelac@redhat.com>
References: <cover.1281256324.git.zkabelac@redhat.com>
Message-ID: <2325e2d6c9c6a58e6525707dcf4839455d89063d.1281256324.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move pool destruction before lvm2_exit so it's not being reported
as leaked pool.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index cf62751..937d81d 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -131,10 +131,10 @@ void dmeventd_lvm2_exit(void)
 
 	if (!--_register_count) {
 		lvm2_run(_lvm_handle, "_memlock_dec");
-		lvm2_exit(_lvm_handle);
-		_lvm_handle = NULL;
 		dm_pool_destroy(_mem_pool);
 		_mem_pool = NULL;
+		lvm2_exit(_lvm_handle);
+		_lvm_handle = NULL;
 	}
 
 	pthread_mutex_unlock(&_register_mutex);
-- 
1.7.2.1


