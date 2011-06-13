From: Joe Thornber <thornber@redhat.com>
Date: Mon, 13 Jun 2011 14:50:07 +0100
Subject: [PATCH v1 00/30] Ext4 snapshots
In-Reply-To: <BANLkTin0Wg9LMjRtHQhyu8rBwU7dQLNW-w@mail.gmail.com>
References: <alpine.LFD.2.00.1106091012030.4138@dhcp-27-109.brq.redhat.com>
	<BANLkTin0RKZbDmB1movombH9o4HDpTnvFw@mail.gmail.com>
	<alpine.LFD.2.00.1106091443370.4138@dhcp-27-109.brq.redhat.com>
	<BANLkTinEJ6235sPNz_f92nfN0ac4qSnHtw@mail.gmail.com>
	<alpine.LFD.2.00.1106101044350.4502@dhcp-27-109.brq.redhat.com>
	<BANLkTikdmT5vjXJHnRTT-=z8zFVAx+Y6_w@mail.gmail.com>
	<alpine.LFD.2.00.1106131204330.4328@dhcp-27-109.brq.redhat.com>
	<BANLkTinQpXfY=WXmm6BMUErQBF8nNL1fSg@mail.gmail.com>
	<alpine.LFD.2.00.1106131502160.4328@dhcp-27-109.brq.redhat.com>
	<BANLkTin0Wg9LMjRtHQhyu8rBwU7dQLNW-w@mail.gmail.com>
Message-ID: <20110613135007.GC3049@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jun 13, 2011 at 04:26:16PM +0300, Amir G. wrote:
> with ext4, snapshots reads may cause extra seeks, but main fs will
> stay optimized for reads.
> with thinp and multisnap, there is no optimization for read from one
> specific target, but I admit that can change in the future when auto defrag
> heuristics are applies to multisnap.

I'm going to keep things symmetrical. A lot of use cases involve
pointing at an arbitrary snapshot and saying "that's now my master".
This is connected to why I support arbitrary depth of recursive
snapshots too.

- Joe


