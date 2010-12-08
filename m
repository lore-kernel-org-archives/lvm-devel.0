From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:49 +0100
Subject: [PATCH 3/9] Add lvm_do_unlock_fs
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <7fdeaacd697096d1834a15ff4390aa0b62297884.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce lvm_do_unlock_fs() function to call lvm's fs_unlock()
while holding lvm_lock mutex.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    7 +++++++
 daemons/clvmd/lvm-functions.h |    1 +
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 0520ae9..187acc2 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -894,6 +894,13 @@ struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name)
 	return v;
 }
 
+void lvm_do_unlock_fs(void)
+{
+	pthread_mutex_lock(&lvm_lock);
+	fs_unlock();
+	pthread_mutex_unlock(&lvm_lock);
+}
+
 /* Called to initialise the LVM context of the daemon */
 int init_clvm(int using_gulm, char **argv)
 {
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index 97153d4..6558863 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -36,5 +36,6 @@ extern char *get_last_lvm_error(void);
 extern void do_lock_vg(unsigned char command, unsigned char lock_flags,
 		      char *resource);
 extern struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name);
+void lvm_do_unlock_fs(void);
 
 #endif
-- 
1.7.3.3


