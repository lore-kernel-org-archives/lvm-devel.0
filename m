From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 29 Mar 2010 17:27:21 +0200
Subject: [PATCH 3/7] Release pool in the same reversed order
In-Reply-To: <cover.1269876115.git.zkabelac@redhat.com>
References: <cover.1269876115.git.zkabelac@redhat.com>
Message-ID: <a60b2197b0cfc0d748f4a8859b0b2b50d9f0739b.1269876115.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 37900e4..bff60b4 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -105,11 +105,11 @@ void dmeventd_lvm2_exit(void)
 	pthread_mutex_lock(&_register_mutex);
 
 	if (!--_register_count) {
-		dm_pool_destroy(_mem_pool);
-		_mem_pool = NULL;
 		lvm2_run(_lvm_handle, "_memlock_dec");
 		lvm2_exit(_lvm_handle);
 		_lvm_handle = NULL;
+		dm_pool_destroy(_mem_pool);
+		_mem_pool = NULL;
 	}
 
 	pthread_mutex_unlock(&_register_mutex);
-- 
1.7.0.1


