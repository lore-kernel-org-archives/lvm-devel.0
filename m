From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 01:01:31 +0000
Subject: [PATCH 15/23] Add test check for find_config_str
In-Reply-To: <0b3634555ba5dfe0300d98e5da7511faa13dcbc5.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<0b3634555ba5dfe0300d98e5da7511faa13dcbc5.1292945707.git.zkabelac@redhat.com>
Message-ID: <20110105010131.GJ10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 04:41:47PM +0100, Zdenek Kabelac wrote:
> It looks like there should be some error code returned from _read_desc
> when something fails.
 
No need - the code is just using default values of "" and 0.

> -	*desc = dm_pool_strdup(mem, d);
> +	*desc = (d) ? dm_pool_strdup(mem, d) : NULL;
  
Superfluous - this follows

        d = find_config_str(cft->root, "description", "");

which returns "" on failure so d is never NULL.

Alasdair


