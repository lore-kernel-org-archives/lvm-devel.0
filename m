From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:30:05 +0100
Subject: [PATCH 19/30] Fix constness warning
In-Reply-To: <ce28656e64b2da18d26c3de9b17f33cbb869533e.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<ce28656e64b2da18d26c3de9b17f33cbb869533e.1287994530.git.zkabelac@redhat.com>
Message-ID: <87aam25zv6.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:26 +0200,
Zdenek Kabelac wrote:
> 
> After update of device_from_pvid API fix few constness warnings
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack.  But all this casting suggests we should change types for some of these functions (eg, info_from_pvid).


