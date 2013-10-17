From: Nir Soffer <nsoffer@redhat.com>
Date: Thu, 17 Oct 2013 15:25:58 -0400 (EDT)
Subject: [PATCH] Fix return value of persistent_filters_dump if rename failed
In-Reply-To: <814115096.5040864.1382037894796.JavaMail.root@redhat.com>
Message-ID: <728848037.5041389.1382037958376.JavaMail.root@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>From eeae04cf523e0c3050d5c686b29fb53316d3c760 Mon Sep 17 00:00:00 2001
From: Nir Soffer <nsoffer@redhat.com>
Date: Thu, 17 Oct 2013 21:18:06 +0300
Subject: [PATCH] Fix return value of persistent_filters_dump if rename failed

---
 lib/filters/filter-persistent.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 14a3480..f068369 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -253,9 +253,11 @@ static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
    if (lvm_fclose(fp, tmp_file))
        goto_out;
 
-   if (rename(tmp_file, pf->file))
+   if (rename(tmp_file, pf->file)) {
        log_error("%s: rename to %s failed: %s", tmp_file, pf->file,
              strerror(errno));
+       goto out;
+   }
 
    r = 1;
 
-- 
1.8.3.1


