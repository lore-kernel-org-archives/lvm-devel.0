From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 26 Apr 2010 16:35:28 +0200
Subject: [PATCH 08/22] Replicator: extend volume_group with list of VGs
In-Reply-To: <20100426142751.GQ23791@agk-dp.fab.redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<bc8252d38b689d788689562d40751a4f31c0daf1.1271085009.git.zkabelac@redhat.com>
	<20100426142751.GQ23791@agk-dp.fab.redhat.com>
Message-ID: <4BD5A4B0.7060403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.4.2010 16:27, Alasdair G Kergon napsal(a):
> Also initialise the new fields and add to vg_validate as part of this patch, to
> ensure internal data consistency.

My plan here is to introduce one common routine for creation of volume_group
structure - not yet finished - so it should be handled there.

For now there is 'lazy' initialization of fields before it's usage - of
course, requires to not touch these fields on unexpected occasions.
This should be fixed once the common routine will be there.

Zdenek


