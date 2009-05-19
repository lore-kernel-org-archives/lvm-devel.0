From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 19 May 2009 18:50:28 +0100
Subject: Re: LVM2 ./WHATS_NEW daemons/clvmd/clvm.h daemons/ ...
In-Reply-To: <20090519103905.25884.qmail@sourceware.org>
References: <20090519103905.25884.qmail@sourceware.org>
Message-ID: <20090519175028.GA5125@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 19, 2009 at 10:39:05AM -0000, mbroz at sourceware.org wrote:
> 	Add infrastructure for queriying for remote locks.
 	
> +++ LVM2/lib/locking/locking_types.h	2009/05/19 10:39:00	1.16
>  struct locking_type {
>  	uint32_t flags;
>  	lock_resource_fn lock_resource;
> +	lock_resource_query_fn lock_resource_query;
>  
>  	reset_lock_fn reset_locking;
>  	fin_lock_fn fin_locking;

What happens if I attempt to load an old locking shared object into the
new version of the binary?

Alasdair


