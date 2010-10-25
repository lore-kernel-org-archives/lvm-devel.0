From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 10:49:11 +0100
Subject: [PATCH 04/30] Fix NULL pointer dereference
In-Reply-To: <12027a536f66f50657c23bb7bed13380c590f423.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<12027a536f66f50657c23bb7bed13380c590f423.1287994529.git.zkabelac@redhat.com>
Message-ID: <87wrp661rc.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:11 +0200,
Zdenek Kabelac wrote:
> 
> vg pointer is not yet initialized in this place and vgname must be used.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

ack


