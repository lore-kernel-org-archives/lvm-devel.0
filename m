From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:03:17 +0100
Subject: [PATCH 09/30] Reuse result of previous strchr.
In-Reply-To: <1ded298d3c909b9ebdcedcf9c275c201c9e4861c.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<1ded298d3c909b9ebdcedcf9c275c201c9e4861c.1287994530.git.zkabelac@redhat.com>
Message-ID: <87pquy613u.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:16 +0200,
Zdenek Kabelac wrote:
> 
> clang Argument with 'nonnull' attribute passed null
> Reuse result of the last strchr call - it also makes sure,
> 'st' point is nonnull for next strchr call.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack


