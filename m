From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:25 +0200
Subject: [PATCH 18/30] Use const pointer for return value of dm_basename
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <090966787d1610aa086bad8ca1e53d0cb23cd34a.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix pointer created from passed input const pointer.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h |    2 +-
 libdm/libdm-string.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 7ed60be..e2f2673 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -955,7 +955,7 @@ int dm_snprintf(char *buf, size_t bufsize, const char *format, ...)
 /*
  * Returns pointer to the last component of the path.
  */
-char *dm_basename(const char *path);
+const char *dm_basename(const char *path);
 
 /**************************
  * file/stream manipulation
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index ce05a10..d8fca1a 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -123,11 +123,11 @@ int dm_snprintf(char *buf, size_t bufsize, const char *format, ...)
 	return n;
 }
 
-char *dm_basename(const char *path)
+const char *dm_basename(const char *path)
 {
-	char *p = strrchr(path, '/');
+	const char *p = strrchr(path, '/');
 
-	return p ? p + 1 : (char *) path;
+	return p ? p + 1 : path;
 }
 
 int dm_asprintf(char **result, const char *format, ...)
-- 
1.7.3.1


