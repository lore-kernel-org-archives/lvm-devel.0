From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 00:49:06 +0000
Subject: [PATCH 15/23] Add test check for find_config_str
In-Reply-To: <4D11CC49.1070609@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<0b3634555ba5dfe0300d98e5da7511faa13dcbc5.1292945707.git.zkabelac@redhat.com>
	<4D10E492.6090805@redhat.com> <4D11CC49.1070609@redhat.com>
Message-ID: <20110105004906.GI10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 22, 2010 at 11:00:41AM +0100, Zdenek Kabelac wrote:
> >> -	get_config_uint32(cft->root, "creation_time", &u);
> >> +	(void) get_config_uint32(cft->root, "creation_time", &u);
> > 
> > What's wrong here? I thought that this is needed only
> > if is defined with warn_if_unused_result?
> 
> When we ignore return value - we should do that explicitly
> when we test all other cases - it's being reported as suspicious.
> 
> IMHO more important question here is - if it's correct to have
> this function returning void.
 
Exactly - the real problem is: what if the field is not present?
Well the code seems to permit that:
It uses a description of "" if there's no description, and a time
of 0 if there's no creation_time.

So I think (void) was indeed the intention.

Alasdair


