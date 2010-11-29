From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:22:59 +0000
Subject: [PATCH 26/29] Add stack traces for dev_set/close_immediate error path
In-Reply-To: <acfd28ed06270c5e3ccb1ffae903c48a9e2a3bc2.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<acfd28ed06270c5e3ccb1ffae903c48a9e2a3bc2.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129212259.GJ29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:30AM +0100, Zdenek Kabelac wrote:
> +	if (!dev_set(dev, UINT64_C(0), (size_t) sectors << SECTOR_SHIFT, value))
> +		stack;
> +
>  	dev_flush(dev);
> -	dev_close_immediate(dev);
> +
> +	if (!dev_close_immediate(dev))
> +                stack;

Ack.

Alasdair


