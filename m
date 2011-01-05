From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 01:22:27 +0000
Subject: [PATCH 20/23] exit if lvmchache_init fails
In-Reply-To: <a643f11abefe02b16de3b627c882b438cb7d4f57.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<a643f11abefe02b16de3b627c882b438cb7d4f57.1292945707.git.zkabelac@redhat.com>
Message-ID: <20110105012227.GN10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 04:41:52PM +0100, Zdenek Kabelac wrote:
>  	reset_locking();
> -	lvmcache_init();
> +	if (!lvmcache_init())
> +		_exit(ECMD_FAILED);
>  	dev_close_all();
  
Ack.

Not ideal, but we actually already have some existing tricky cleanup problems
here that I never fixed, so just add a FIXME "Clean up properly here!" to that
_exit().

Alasdair


