From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 22:26:18 -0500
Subject: [PATCH 12/12] Remove init_full_scan_done(0) call after create_toolcontext().
Message-ID: <1228965978-19132-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It is not as obvious init_full_scan_done(0) is unneeded.  This sets the
_full_scan_done variable in lvm-globals.c which influences dev-cache.c behavior.
_full_scan_done is initialized to 0 at compile time.  The only place that
sets it to non-zero value is dev-cache.c:_full_scan().

create_toolcontext() calls _init_dev_cache() and _init_filters() - this is
where we could possibly call _full_scan() - wouldn't think so but let's be
sure.  Clearly _init_dev_cache() does not do any actual scanning but just
sets up basic structures and fills in the list of directories or loopfiles
to later scan.  _init_filters() does call into dev-cache.c if
persistent_filter_load() is called.  In persistent_filter_load() we are
opening the .cache file and reading any entries, and note that _read_array()
calls into dev_cache_get().  This call into dev_cache_get() will try to
lookup the device name in the devices cache, and if not found, will insert
it into the devices cache.  At the time of these dev-cache-get() calls,
the devices cache is empty, so each device in the persistent .cache file
will result in _insert() call inside dev_cache_get().  This call could
fail, in which case the subsequent dm_hash_lookup() will fail and
_full_scan(0) will be called.  Will _full_scan(0) call result in
init_full_scan_done(1)?  _full_scan() has this code:
	if (_cache.has_scanned && !dev_scan)
		return;
We know dev_scan == 0, the but what of _cache.has_scanned?  dev_cache_init(),
called earlier, intiialized this to 0.  _cache.has_scanned could be set from
dev_cache_scan().  dev_cache_scan() is called only from
persistent_filter_wipe() and persistent_filter_load().  In
persistent_filter_load(), dev_cache_scan() may be called after _read_array(),
so this doesn't apply.  persistent_filter_wipe() is called from a few of
the lvm tool implementation routines (e.g. pvcreate.c), and dev_iter_create().
None of the tool implementation routines apply, and we wouldn't think any
init code should be iterating through the devices cache by dev_iter_create().
A quick check of the callers confirms this, and so we conclude
_cache.has_scanned must be 0.  Thus, our _full_scan(0) call from dev_cache_get()
will result in a scanning of the devices in the system, as well as
init_full_scan_done(1) being called.  So the init_full_scan_done(0) after
create_toolcontext() is significant.  We didn't think _init_filters() would
result in a scan of the devices in the system, but it does.  But why are
we setting init_full_scan_done(0) here?

Is this a bug?  Why are we setting _full_scan_done = 0 here when we've
already read the config file(s) for the 'scan' and other variables, then
scanned the system for devices as shown above?  Why do we need to act as
though we haven't scanned?  Other places in the code call
init_full_scan_done(0) when they want to indicate devices may have
changed.  But there's nothing indicating to me that something has changed
between the middle of create_toolcontext() where we call _init_filters()
to scan for devices and this call to init_full_scan_done(0).  I have to
conclude it is not needed.

As with init_mirror_in_sync() and perhaps other global variables, a process
that does a sequence of create_toolcontext()/destroy/create may need to
call init_full_scan_done(0) to reset the variable.  A subsequent patch
should address this case, perhaps by exporting a function that resets the
important global variables or perhaps resets the variables at the bottom of
create_toolcontext().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvmcmdline.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 5e02057..e1e9826 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1091,8 +1091,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_full_scan_done(0);
-
 	return cmd;
 }
 
-- 
1.5.5.1


