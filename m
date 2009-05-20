From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 20 May 2009 10:02:50 +0100
Subject: Re: LVM2 ./WHATS_NEW daemons/clvmd/clvm.h daemons/ ...
In-Reply-To: <20090519103905.25884.qmail@sourceware.org>
References: <20090519103905.25884.qmail@sourceware.org>
Message-ID: <20090520090250.GD5125@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 19, 2009 at 10:39:05AM -0000, mbroz at sourceware.org wrote:
> +++ LVM2/lib/locking/locking.c	2009/05/19 10:39:00	1.58
> +int remote_lock_held(const char *vol)

> +	return mode == LCK_NULL ? 0 : 1;

I think this should still perform the activate_lock_excl() trick 
here in cases where the new function is not defined.

We shouldn't need to break this if someone is still using an
external locking module they have not updated.

Alasdair


