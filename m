From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:47 +0100
Subject: [PATCH 1/9] Add get_lib_cookie
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <3348478e33a102731b73529f56dea3545cd3791f.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Create internal libdm function to access internal cookie value.
If the _lib_cookie is 0 - new value is generated.

This leads to creation of possibly unused semaphore - but currenly
it simplifies patch.

Cookie is automaticaly destroyed when   update_devs() is executed.
This currently makes imposible to use only 1 cookie per whole
executable lifetime - as  dm_udev_wait currently destroys semaphor
when counter drops to 0.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-common.c |   23 +++++++++++++++++++++++
 libdm/libdm-common.h |    1 +
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 2dfa28f..7407163 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -65,6 +65,7 @@ static int _udev_running = -1;
 static int _sync_with_udev = 1;
 static int _udev_checking = 1;
 #endif
+static uint32_t _lib_cookie;
 
 /*
  * Library users can provide their own logging
@@ -811,6 +812,13 @@ int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
 
 void update_devs(void)
 {
+	if (_lib_cookie) {
+		if (!dm_udev_wait(_lib_cookie))
+			stack;
+
+		_lib_cookie = 0;
+	}
+
 	_pop_node_ops();
 }
 
@@ -1295,3 +1303,18 @@ repeat_wait:
 }
 
 #endif		/* UDEV_SYNC_SUPPORT */
+
+int get_lib_cookie(uint32_t *cookie)
+{
+	if (!_lib_cookie) {
+		if (!dm_udev_get_sync_support())
+			return 0;
+
+		if (!dm_udev_create_cookie(&_lib_cookie))
+			return_0;
+	}
+
+	*cookie = _lib_cookie;
+
+	return 1;
+}
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index fcb334f..639e4d5 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -32,4 +32,5 @@ int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
 			    uint32_t read_ahead_flags);
 void update_devs(void);
 
+int get_lib_cookie(uint32_t *cookie);
 #endif
-- 
1.7.3.3


