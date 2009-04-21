From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 21 Apr 2009 14:33:58 -0400
Subject: [PATCH 3/4] Udev integration: add cookie support for dmsetup
In-Reply-To: <49DC978E.4040101@redhat.com>
References: <49DC978E.4040101@redhat.com>
Message-ID: <1240338838.3705.63.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2009-04-08 at 14:24 +0200, Peter Rajnoha wrote:
>  	if (argc == 3)
>  		file = argv[2];
> @@ -565,9 +566,19 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
>  				    _read_ahead_flags))
>  		goto out;
>  
> -	if (!dm_task_run(dmt))
> +	if (!dm_notification_sem_open(&cookie) ||
> +			!dm_notification_sem_inc(cookie) ||
> +			!dm_task_set_cookie(dmt, cookie))
>  		goto out;
>  
> +	if (!dm_task_run(dmt)) {
> +		dm_notification_sem_close(cookie);
> +		goto out;
> +	}
> +
> +	dm_notification_sem_wait_zero(cookie);
> +	dm_notification_sem_close(cookie);
> +
>  	r = 1;


This piece of code could exit without cleanup of the semaphore.  Should
the first 'if' only check !dm_notification_sem_open, and the sem_inc and
set_cookie be '||'d with dm_task_run in the second 'if'?


>  
>  	if (_switches[VERBOSE_ARG])
> @@ -583,6 +594,7 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
>  {
>  	int r = 0;
>  	struct dm_task *dmt;
> +	uint32_t cookie;
>  
>  	if (!(dmt = dm_task_create(DM_DEVICE_RENAME)))
>  		return 0;
> @@ -597,8 +609,18 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
>  	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
>  		goto out;
>  
> -	if (!dm_task_run(dmt))
> +	if (!dm_notification_sem_open(&cookie) ||
> +			!dm_notification_sem_inc(cookie) ||
> +			!dm_task_set_cookie(dmt, cookie))
> +		goto out;
> +
> +	if (!dm_task_run(dmt)) {
> +		dm_notification_sem_close(cookie);
>  		goto out;
> +	}
> +
> +	dm_notification_sem_wait_zero(cookie);
> +	dm_notification_sem_close(cookie);
>  

Same comment as above.  If open fails, then we don't need close.  But in
all other cases we should be calling sem_close.


>  
>  static int _resume(int argc, char **argv, void *data __attribute((unused)))
>  {
> -	return _simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, 1);
> +	uint32_t cookie;
> +
> +	if (!dm_notification_sem_open(&cookie) ||
> +		  !dm_notification_sem_inc(cookie))
> +		return 0;
> +
> +	if (!_simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, cookie, 1)) {
> +		dm_notification_sem_close(cookie);
> +		return 0;
> +	}
> +
> +	dm_notification_sem_wait_zero(cookie);
> +	dm_notification_sem_close(cookie);
> +
> +	return 1;
>  }

Same comment - if sem_inc fails we keep the semaphore, but !_simple()
fails we remove it?



>  
> @@ -913,11 +966,24 @@ error:
>  static int _remove(int argc, char **argv, void *data __attribute((unused)))
>  {
>  	int r;
> +	uint32_t cookie;
>  
>  	if (_switches[FORCE_ARG] && argc > 1)
>  		r = _error_device(argc, argv, NULL);
>  
> -	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
> +	if (!dm_notification_sem_open(&cookie) ||
> +			!dm_notification_sem_inc(cookie))
> +		return 0;
> +
> +	if (!_simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, cookie, 0)) {
> +		dm_notification_sem_close(cookie);
> +		return 0;
> +	}
> +
> +	dm_notification_sem_wait_zero(cookie);
> +	dm_notification_sem_close(cookie);
> +
> +	return 1;
>  }

Same comment as above.




