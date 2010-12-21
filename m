From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Dec 2010 18:32:02 +0100
Subject: [PATCH 15/23] Add test check for find_config_str
In-Reply-To: <0b3634555ba5dfe0300d98e5da7511faa13dcbc5.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<0b3634555ba5dfe0300d98e5da7511faa13dcbc5.1292945707.git.zkabelac@redhat.com>
Message-ID: <4D10E492.6090805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:

> -	*desc = dm_pool_strdup(mem, d);
> +	*desc = (d) ? dm_pool_strdup(mem, d) : NULL;

dm_pool_strdup(NULL) tries to alloc 1 byte and returning pointer, 
and not setting to \0 and calling strlen(NULL).

dunno what was the intention here.

> -	get_config_uint32(cft->root, "creation_time", &u);
> +	(void) get_config_uint32(cft->root, "creation_time", &u);

What's wrong here? I thought that this is needed only
if is defined with warn_if_unused_result?

Milan


