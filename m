From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 15:27:51 +0100
Subject: [PATCH 08/22] Replicator: extend volume_group with list of VGs
In-Reply-To: <bc8252d38b689d788689562d40751a4f31c0daf1.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<bc8252d38b689d788689562d40751a4f31c0daf1.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426142751.GQ23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Also initialise the new fields and add to vg_validate as part of this patch, to
ensure internal data consistency.

Alasdair


