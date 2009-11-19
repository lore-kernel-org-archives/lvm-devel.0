From: Marian Csontos <mcsontos@redhat.com>
Date: Thu, 19 Nov 2009 11:24:43 +0100
Subject: LVM2 tools/lvmcmdlib.c lib/mm/memlock.h lib/mm ...
In-Reply-To: <20091119011158.31472.qmail@sourceware.org>
References: <20091119011158.31472.qmail@sourceware.org>
Message-ID: <4B051CEB.1030204@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/19/2009 02:11 AM, mornfall at sourceware.org wrote:
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	mornfall at sourceware.org	2009-11-19 01:11:57
>
> Modified files:
> 	tools          : lvmcmdlib.c
> 	lib/mm         : memlock.h memlock.c
>
> Log message:
> 	Fix another bug in memlock handling, this time the "global" dmeventd memlock
> 	was preventing device scans in lvconvert --repair running from inside dmeventd.
>
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
>
> --- LVM2/tools/lvmcmdlib.c	2009/02/22 22:11:59	1.9
> +++ LVM2/tools/lvmcmdlib.c	2009/11/19 01:11:57	1.10
> @@ -82,9 +82,9 @@
>   	/* FIXME Temporary - move to libdevmapper */
>   	ret = ECMD_PROCESSED;
>   	if (!strcmp(cmdline, "_memlock_inc"))
> -		memlock_inc();
> +		memlock_inc_daemon();
>   	else if (!strcmp(cmdline, "_memlock_dec"))
> -		memlock_dec();
> +		memlock_dec_daemon();
>   	else
>   		ret = lvm_run_command(cmd, argc, argv);
>
> --- LVM2/lib/mm/memlock.h	2007/08/20 20:55:27	1.4
> +++ LVM2/lib/mm/memlock.h	2009/11/19 01:11:57	1.5
> @@ -20,6 +20,8 @@
>
>   void memlock_inc(void);
>   void memlock_dec(void);
> +void memlock_inc_daemon(void);
> +void memlock_dec_daemon(void);
>   int memlock(void);
>   void memlock_init(struct cmd_context *cmd);
>
> --- LVM2/lib/mm/memlock.c	2009/11/18 18:22:32	1.13
> +++ LVM2/lib/mm/memlock.c	2009/11/19 01:11:57	1.14
> @@ -53,6 +53,7 @@
>
>   static void *_malloc_mem = NULL;
>   static int _memlock_count = 0;
> +static int _memlock_count_daemon = 0;
>   static int _priority;
>   static int _default_priority;
>
> @@ -123,22 +124,61 @@
>   			  strerror(errno));
>   }
>
> +static void _lock_mem_if_needed(void) {
> +	if ((_memlock_count + _memlock_count_daemon) == 1)
> +		_lock_mem();
> +}
> +
> +static void _unlock_mem_if_possible(void) {
> +	if ((_memlock_count + _memlock_count_daemon) == 0)
> +		_unlock_mem();
> +}
> +
>   void memlock_inc(void)
>   {
> -	if (!_memlock_count++)
> -		_lock_mem();
> +	++_memlock_count;
> +	_lock_mem_if_needed();
>   	log_debug("memlock_count inc to %d", _memlock_count);
>   }
>
>   void memlock_dec(void)
>   {
> -	if (_memlock_count&&  (!--_memlock_count))
> -		_unlock_mem();
> -	log_debug("memlock_count dec to %d", _memlock_count);
> -	if (_memlock_count<  0)
> +	if (!_memlock_count)
>   		log_error("Internal error: _memlock_count has dropped below 0.");
>    
Why not to zero _memlock_count here (and _memlock_count_daemon below)?
IMO, simple log_error is not enough. Though I understand this should not 
happen under any conditions, the Murphy's Law says it will happen. And 
when it happens...

...dropping below zero, will result in subsequent 
memlock_inc/memloc_inc_daemon having no effect. (Q: How serious is this 
condition? Could it result in data corruption?)

On the other hand, if it were zeroed, the possible deadlock could be the 
only result.
However, this could happen only when memory is unlocked before it is locked.

Cheers,

-- Marian

> +	--_memlock_count;
> +	_unlock_mem_if_possible();
> +	log_debug("memlock_count dec to %d", _memlock_count);
>   }
>
> +/*
> + * The memlock_*_daemon functions will force the mlockall() call that we need
> + * to stay in memory, but they will have no effect on device scans (unlike
> + * normal memlock_inc and memlock_dec). Memory is kept locked as long as either
> + * of memlock or memlock_daemon is in effect.
> + */
>    
Q: It does not work as proposed now. Does the "will" mean it will once 
implemented?
> +
> +void memlock_inc_daemon(void)
> +{
> +	++_memlock_count_daemon;
> +	_lock_mem_if_needed();
> +	log_debug("memlock_count_daemon inc to %d", _memlock_count_daemon);
> +}
> +
> +void memlock_dec_daemon(void)
> +{
> +	if (!_memlock_count_daemon)
> +		log_error("Internal error: _memlock_count_daemon has dropped below 0.");
>    
...and zero _memlock_count_daemon on error.
> +	--_memlock_count_daemon;
> +	_unlock_mem_if_possible();
> +	log_debug("memlock_count_daemon dec to %d", _memlock_count_daemon);
> +}
> +
> +/*
> + * This disregards the daemon (dmeventd) locks, since we use memlock() to check
> + * whether it is safe to run a device scan, which would normally coincide with
> + * !memlock() -- but the daemon global memory lock breaks this assumption, so
> + * we do not take those into account here.
> + */
>   int memlock(void)
>   {
>   	return _memlock_count;
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>    


