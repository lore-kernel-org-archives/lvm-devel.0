From: Petr Rockai <prockai@redhat.com>
Date: Wed, 30 Jun 2010 14:54:57 +0200
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices (v2)
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228864BC@USINDEVS02.corp.hds.com>
	(Takahiro Yasui's message of "Tue, 29 Jun 2010 03:26:15 -0400")
References: <5C30BE7ED8B03E448B2E104602D4848A59228864BC@USINDEVS02.corp.hds.com>
Message-ID: <8739w4lly6.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Taka,

Takahiro Yasui <takahiro.yasui@hds.com> writes:
>  int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer)
>  {
>  	struct device_area where;
> +	int ret;
>  
>  	if (!dev->open_count)
>  		return_0;
>  
> +	if (!_dev_is_valid(dev))
> +		return 0;
Maybe return_0 here?

> +
>  	where.dev = dev;
>  	where.start = offset;
>  	where.size = len;
>  
> -	return _aligned_io(&where, buffer, 0);
> +	ret = _aligned_io(&where, buffer, 0);
> +	if (!ret)
> +		_dev_inc_error_count(dev);
> +
> +	return ret;
>  }
>  
>  /*
> @@ -662,17 +684,25 @@ int dev_append(struct device *dev, size_
>  int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer)
>  {
>  	struct device_area where;
> +	int ret;
>  
>  	if (!dev->open_count)
>  		return_0;
>  
> +	if (!_dev_is_valid(dev))
> +		return 0;
(and here)

> +
>  	where.dev = dev;
>  	where.start = offset;
>  	where.size = len;
>  
>  	dev->flags |= DEV_ACCESSED_W;
>  
> -	return _aligned_io(&where, buffer, 1);
> +	ret = _aligned_io(&where, buffer, 1);
> +	if (!ret)
> +		_dev_inc_error_count(dev);
> +
> +	return ret;
Hmm. Should write errors count towards this? What happens if the device
just rejects writes -- could this break code by yanking the device
completely? This means, IIUIC, that any subsequent rescan that may
happen won't see the device even if the failure was due to failing
writes and the device reads just fine.

I guess this is a corner case, but I would be surprised if there were
any significant use-cases for tracking write errors for this purpose:
the primary reason for the code is repeated read errors, I believe?

Of course, not writing to the device that cannot be read is certainly
prudent -- do not remove the check near the top of dev_write if you
decide to not track write errors as per above.

Other than this, I think the patch looks OK.

Yours,
   Petr.


