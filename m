From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Oct 2009 13:59:52 +0100
Subject: [PATCH 01/13] Replicator: export out_ function for modules
In-Reply-To: <4ACF30EE.9000901@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<20091007150503.GC3054@agk-dp.fab.redhat.com>
	<4ACDC6AD.2090207@redhat.com> <4ACF30EE.9000901@redhat.com>
Message-ID: <20091009125952.GD3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 09, 2009 at 02:47:42PM +0200, Zdenek Kabelac wrote:
> -#define outnl(f) do {if (!f->nl(f)) return_0;} while (0)
> +#define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
 
That was what I was thinking, yes.

Alasdair


