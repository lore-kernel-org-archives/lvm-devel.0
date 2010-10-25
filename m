From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 10:56:50 +0100
Subject: [PATCH 02/30] Use dm_pool_grow_object embeded strlen for 0 delta
In-Reply-To: <c8607124ac3c8c7f5d92aafc1e266732df8f2abc.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<c8607124ac3c8c7f5d92aafc1e266732df8f2abc.1287994529.git.zkabelac@redhat.com>
Message-ID: <87vd4q61el.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:09 +0200,
Zdenek Kabelac wrote:
> 
> Use internal strlen for 0
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack, but I don't think this improves the readablility of the code.  The problem is the extra semantics of zero as the third arg to dm_pool_grow_object() (probably my bad).  Maybe introduce a new pool method dm_pool_grow_string(struct dm_pool *p, const char *str) ?


