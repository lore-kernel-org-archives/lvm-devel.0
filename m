From: Milan Broz <mbroz@redhat.com>
Date: Fri, 04 Mar 2011 17:56:01 +0100
Subject: LVM2/lib/mm memlock.c
In-Reply-To: <20110218145104.6981.qmail@sourceware.org>
References: <20110218145104.6981.qmail@sourceware.org>
Message-ID: <4D7119A1.3090209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/18/2011 03:51 PM, zkabelac at sourceware.org wrote:

> 	Memory unlock allows 1 page difference

> --- LVM2/lib/mm/memlock.c	2011/02/18 14:16:12	1.34
> +++ LVM2/lib/mm/memlock.c	2011/02/18 14:51:04	1.35
> @@ -343,9 +343,15 @@

> +			if ((_mstats + 4096) < unlock_mstats)

Can we use getpagesize() here please?

Milan


