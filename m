From: Jim Meyering <jim@meyering.net>
Date: Mon, 16 Jul 2007 19:20:58 +0200
Subject: [PATCH] Don't leak a file descriptor when flock fails.
Message-ID: <87ps2sz2md.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I was looking through the code and spotted a minor problem.
A failed flock can lead to a file-descriptor leak here:

	* lib/locking/file_locking.c (_lock_file): Close fd upon flock failure.

Here's the original code, then the patch:

            do {
                    if ((ll->lf > -1) && close(ll->lf))
                            log_sys_error("close", file);

                    if ((ll->lf = open(file, O_CREAT | O_APPEND | O_RDWR, 0777))
                    ...
                    r = flock(ll->lf, operation);
                    old_errno = errno;
                    ...
                    if (r) {
                            errno = old_errno;
                            log_sys_error("flock", ll->res);
                            goto err;
                    }

                    if (!stat(ll->res, &buf1) && !fstat(ll->lf, &buf2) &&
                        !memcmp(&buf1.st_ino, &buf2.st_ino, sizeof(ino_t)))
                            break;
            } while (!(flags & LCK_NONBLOCK));

            list_add(&_lock_list, &ll->list);
            return 1;

          err:
            dm_free(ll->res);
            dm_free(ll);
            return 0;
    }

It may well be that whenever _lock_file fails, the caller always
bails out, so the FD leak doesn't really matter, but fixing it now
means we don't have to audit all callers, and will also prevent further
reports :-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 56f579e..27ad8f3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.27 -
 ================================
+  Don't leak a file descriptor when flock fails.
   Fix configure libdevmapper.h check when --with-dmdir is used.
   Turn _add_pv_to_vg() into external library function add_pv_to_vg().
   Add pv_by_path() external library function.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 3126411..1ac76c1 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -185,6 +185,7 @@ static int _lock_file(const char *file, int flags)
 		if (r) {
 			errno = old_errno;
 			log_sys_error("flock", ll->res);
+			close(ll->lf);
 			goto err;
 		}

--
1.5.3.rc1.27.ga5e40


