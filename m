From: Petr Rockai <prockai@redhat.com>
Date: Wed, 24 Feb 2010 16:39:07 +0100
Subject: [PATCH 1/2] Always query device by uuid only.
In-Reply-To: <1266932816-5621-1-git-send-email-mbroz@redhat.com> (Milan Broz's
	message of "Tue, 23 Feb 2010 14:46:55 +0100")
References: <1266932816-5621-1-git-send-email-mbroz@redhat.com>
Message-ID: <878waitzhg.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> --- a/lib/activate/dev_manager.c
> +++ b/lib/activate/dev_manager.c
> @@ -123,12 +123,14 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
>  {
>  	int r = 0;
>  	struct dm_task *dmt;
> -	int dmtask;
>  
> -	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
> -
> -	if (!(dmt = _setup_task(name, dlid, 0, dmtask, major, minor)))
> -		return_0;
> +	if (mknodes) {
> +		if (!(dmt = _setup_task(name, dlid, 0, DM_DEVICE_MKNODES, major, minor)))
> +			return_0;
> +	} else {
> +		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_INFO, major, minor)))
> +			return_0;
> +	}

Can we instead have

if (!(dmt = _setup_task(mknodes ? name : NULL, dlid, 0, dmtask, major, minor)))
	return_0;

please?

Otherwise, ACK.


