From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 11:05:21 +0200
Subject: LVM2 ./WHATS_NEW lib/activate/activate.h lib/a ...
In-Reply-To: <4BED114A.1090507@redhat.com>
References: <20100513183841.1542.qmail@sourceware.org>	<20100513234711.GP2377@agk-dp.fab.redhat.com>
	<4BED114A.1090507@redhat.com>
Message-ID: <4BED1251.6010107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.5.2010 11:00, Milan Broz napsal(a):
> On 05/14/2010 01:47 AM, Alasdair G Kergon wrote:
>> Mixing up types there.
>> name is a dm device name
>>
>>   
> yep. ok with that patch? (we have no mempool available there, that's why
> dm_strdup)
> 
> diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
> index 710b3ae..d01bd63 100644
> --- a/lib/activate/dev_manager.c
> +++ b/lib/activate/dev_manager.c
> @@ -133,7 +133,7 @@ int device_is_usable(struct device *dev)

>  	r = 1;
>  
>        out:
> +	if (vgname)

- this check is not really needed and done by dm_free itself.

> +		dm_free(vgname);

Zdenek


