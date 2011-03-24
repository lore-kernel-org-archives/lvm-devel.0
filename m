From: Milan Broz <mbroz@redhat.com>
Date: Thu, 24 Mar 2011 13:30:51 +0100
Subject: [PATCH 1/4] Reading of unitialized memory
In-Reply-To: <3203b388b56009070e7de15bde71d0ded8d9a91f.1300965223.git.zkabelac@redhat.com>
References: <cover.1300965223.git.zkabelac@redhat.com>
	<3203b388b56009070e7de15bde71d0ded8d9a91f.1300965223.git.zkabelac@redhat.com>
Message-ID: <4D8B397B.5030805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/24/2011 12:16 PM, Zdenek Kabelac wrote:

>  		if (!(lvm->map = dm_pool_zalloc(mem, sizeof(*lvm->map)
> -					     * ll->lv->le_count)))
> +					     * (ll->lv->le_count + 1))))

I do not like such fixes, but because this code is really not going
to be used in future (and I know how complicated it is), let's
"fix" it this way.

turn a blind eye to ... ACK :-)

Milan


