From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 10 Jun 2013 10:00:03 +0200
Subject: [PATCH 3/3] udev: Use udev monitor
In-Reply-To: <20130608095657.GC3132@mail.waldi.eu.org>
References: <20130608094939.GA3065@mail.waldi.eu.org>
	<20130608095657.GC3132@mail.waldi.eu.org>
Message-ID: <51B58783.5060409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Bastian,

On 08.06.2013 11:56, Bastian Blank wrote:
> ---
>  libdm/libdm-common.c |   93 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 92 insertions(+), 1 deletion(-)

> +static unsigned int _udev_monitor_inflight;

The counter is a global variable - what if we have several cookies
being processed? This needs to be wrapped and referenced by cookie id then.

>  static int _udev_wait(uint32_t cookie)
>  {
> +	struct udev_monitor *monitor;
> +	struct pollfd p = { -1, POLLIN, 0 };
> +	int r = 0;
> +
>  	if (!cookie || !dm_udev_get_sync_support())
>  		return 1;
>  
> -	return_0;
> +	cookie &= ~DM_UDEV_FLAGS_MASK;
> +	log_debug("Udev cookie 0x%" PRIx32 " expected", cookie);
> +
> +	monitor = _get_udev_monitor();
> +
> +	p.fd = udev_monitor_get_fd(monitor);
> +
> +	while (!r)
> +	{
> +		// TODO: timeout

Yes, that would be nice in my opinion as well (once I wanted to add
timeouts for semaphores even, but...). If providing a timeout, we need
to take great care about numerous devices being processed under one
cookie - so it needs to be a function of that number of devices (e.g.
activating 1000 and more LVs under one cookie could really take a long
time with udev - so we need to take care to not provide premature timeouts).

Thing is, that if udev works correctly (with kernel, of course), we
don't need timeouts. But udev kills its forked processes on timeout
(which is normally 3 min I think). I've reported this to udev people and
I asked them for a new rule that could provide a "cleanup" on timeout
directly in udev rules, but they don't seem to change anything here. The
problem here is that if this killing happens in udev on timeout, the
udev db is incomplete and we can't detect this state easily.

So the timeout on LVM side is just a workaround we could possibly
provide until udev gets fixed in this area. But a complete solution here
is on udev side imho.

> +		poll(&p, 1, -1);
> +
> +		struct udev_device *device = udev_monitor_receive_device(monitor);
> +		struct udev_list_entry *l;
> +
> +		udev_list_entry_foreach(l, udev_device_get_properties_list_entry(device))
> +		{
> +			if (strcmp("DM_COOKIE", udev_list_entry_get_name(l)) == 0)
> +			{
> +				const char *value = udev_list_entry_get_value(l);
> +				uint32_t cookie_current = strtol(value, NULL, 10) & ~DM_UDEV_FLAGS_MASK;
> +				log_debug("Udev cookie 0x%" PRIx32 " found", cookie_current);
> +
> +				if (cookie == cookie_current)
> +					r = 1;

This breaks with "success"...

> +				break;
> +			}
> +		}
> +
> +		udev_device_unref(device);
> +	}
> +
> +	_pop_udev_monitor_inflight();
> +

...pops just one value for one event...

> +	return r;

...but we could still have several devices under one cookie - e.g.
processing several LVs at once (which is common in LVM code, for example
activating the whole VG with several LVs). So this part needs fixing.

Peter


