From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:08:57 +0100
Subject: [PATCH 10/30] Fix potential NULL pointer dereference
In-Reply-To: <0fe6e9c0c86a7a0487fb7a6eead6fc7b4760a123.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<0fe6e9c0c86a7a0487fb7a6eead6fc7b4760a123.1287994530.git.zkabelac@redhat.com>
Message-ID: <87lj5m60ue.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:17 +0200,
Zdenek Kabelac wrote:
> 
> Makes clang happier as it covers all code paths and avoids NULL pointer
> dereference through com pointer (which is NULL by default static
> initialisation).
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack


