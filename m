From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 15:34:04 +0100
Subject: [PATCH 09/22] Replicator: add sorted vgs_list
In-Reply-To: <4ac472dac5d9b6fe6833e169e5ccddceab1fa014.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<4ac472dac5d9b6fe6833e169e5ccddceab1fa014.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426143404.GR23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12, 2010 at 05:21:37PM +0200, Zdenek Kabelac wrote:
> Introduce struct vgs_list to store information about needed
> volume group name, vgid, flags and the pointer to opened VG.
 
Why does this need a new structure?
How does this interact with internal caches?
How does this interact with 'struct volume_group' itself?  (The fields are
already part of it so why is a new struct needed?)

Alasdair


