From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 19 May 2009 19:03:22 +0100
Subject: Re: LVM2 ./WHATS_NEW daemons/clvmd/clvm.h daemons/ ...
In-Reply-To: <20090519103905.25884.qmail@sourceware.org>
References: <20090519103905.25884.qmail@sourceware.org>
Message-ID: <20090519180322.GB5125@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 19, 2009 at 10:39:05AM -0000, mbroz at sourceware.org wrote:
> 	Add infrastructure for queriying for remote locks.
 	

> +int remote_lock_held(const char *vol)

> +typedef int (*lock_resource_query_fn) (const char *resource, int *mode);

Doesn't matter for this release, but perhaps we can place both local and remote
queries behind the same lock_resource_query interface now.

Alasdair


