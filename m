From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:18:26 +0100
Subject: [PATCH 14/30] Fix missing initilisation to 0
In-Reply-To: <9fb7596966d9e773570ca7b66ebedfc0b4289fa1.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<9fb7596966d9e773570ca7b66ebedfc0b4289fa1.1287994530.git.zkabelac@redhat.com>
Message-ID: <87iq0q60el.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:21 +0200,
Zdenek Kabelac wrote:
> 
> Missing init value for 'found' which is later tested and may
> containe garbage value.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack


