From: Milan Broz <mbroz@redhat.com>
Date: Tue, 13 Sep 2011 16:55:10 +0200
Subject: [PATCH] Retry dm device removal if busy
In-Reply-To: <4E6F6958.5020609@redhat.com>
References: <4E6F6958.5020609@redhat.com>
Message-ID: <4E6F6ECE.4070700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/13/2011 04:31 PM, Peter Rajnoha wrote:
> If a dm device is being opened in parallel while we're
> trying to remove it, we'll end up with an error that
> the device is busy. This is a legitimate error, but
> with udev in play and asynchronous events generated
> as a result of using the WATCH udev rule, we can get
> into a situation where such failure is very unpleasant.
> 
> Let's try the removal a few times then. Though this is
> not a complete solution to the problem, let's use this
> until we have one.

Before anyone start to complain:

we spent incredible amount of time with fixing the unfixable,

I really prefer make it to work despite it is not 100% correct.
It is ugly but it will allow us to fix another things and not
waste time here for now.

This approach is already used in cryptsetup, mdadm and perhaps
other similar packages.

ACK for me (in principle), just with different time (see below).

(please keep this as internal workaround, no lvm.conf bloat etc. Users
are already very very confused by trillion switches.)

> diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
> index 816f1e6..e4a3a1f 100644
> --- a/libdm/ioctl/libdm-iface.c
> +++ b/libdm/ioctl/libdm-iface.c
> @@ -1539,11 +1539,14 @@ static const char *_sanitise_message(char *message)
>  	return sanitised_message;
>  }
>  
> +#define DM_REMOVE_IOCTL_RETRIES 5

I would use the same as array stop for mdadm : 25 x usleep(200000).

#define DM_REMOVE_IOCTL_RETRIES 25

maybe lower that to 10 ?

> +
>  static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
>  				     unsigned repeat_count)
>  {
>  	struct dm_ioctl *dmi;
>  	int ioctl_with_uevent;
> +	int retries = DM_REMOVE_IOCTL_RETRIES;
>  
>  	dmi = _flatten(dmt, repeat_count);
>  	if (!dmi) {
> @@ -1627,11 +1630,23 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
>  		  dmt->sector, _sanitise_message(dmt->message),
>  		  dmi->data_size);
>  #ifdef DM_IOCTLS
> +repeat_dm_ioctl:
>  	if (ioctl(_control_fd, command, dmi) < 0) {
>  		if (errno == ENXIO && ((dmt->type == DM_DEVICE_INFO) ||
>  				       (dmt->type == DM_DEVICE_MKNODES) ||
>  				       (dmt->type == DM_DEVICE_STATUS)))
>  			dmi->flags &= ~DM_EXISTS_FLAG;	/* FIXME */
> +		/*
> +		 * FIXME: This is a workaround for asynchronous events generated
> +		 *        as a result of using the WATCH udev rule with which we
> +		 *        have no way of synchronizing. Processing such events in
> +		 *        parallel causes devices to be open.
> +		 */
> +		else if (errno == EBUSY && (dmt->type == DM_DEVICE_REMOVE) && retries--) {
> +			log_debug("device-mapper: device is busy, retrying removal");
> +			sleep(1);

usleep(200000);

It would be good to not retry if we are sure that it is not transient use of device.
Not sure if it is possible here though.

> +			goto repeat_dm_ioctl;
> +		}
>  		else {
>  			if (_log_suppress)
>  				log_verbose("device-mapper: %s ioctl "

Milan


