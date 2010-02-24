From: Milan Broz <mbroz@redhat.com>
Date: Wed, 24 Feb 2010 12:56:09 +0100
Subject: [PATCH 1/2] Always query device by uuid only.
In-Reply-To: <4B8511AB.3080305@redhat.com>
References: <1266932816-5621-1-git-send-email-mbroz@redhat.com>	<20100223203902.GA31973@redhat.com>
	<4B8511AB.3080305@redhat.com>
Message-ID: <4B8513D9.5060107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/24/2010 12:46 PM, Milan Broz wrote:
> -	log_debug("Getting device info for %s", name);
> -	r = _info(NULL, dlid, with_mknodes, with_open_count,
> +	log_debug("Getting device info for %s [%s]", name, dlid);
> +	r = _info(name, dlid, with_mknodes, with_open_count,

ok, so I did already three times the same mistake and re-introduced
fallback to name query. Name query should be only in mknodes now...

sigh. Either I am idiot or split of mknodes and info dm calls
in _info_run is confusing (or both).

I'll post another patch...

Milan


