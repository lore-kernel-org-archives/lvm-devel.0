From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 08 Oct 2009 10:56:47 +0200
Subject: [PATCH 03/13] Replicator: add lvm support
In-Reply-To: <20091007150734.GD3054@agk-dp.fab.redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-3-git-send-email-zkabelac@redhat.com>
	<20091007150734.GD3054@agk-dp.fab.redhat.com>
Message-ID: <4ACDA94F.4080405@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.10.2009 17:07, Alasdair G Kergon napsal(a):
> On Mon, Oct 05, 2009 at 04:00:30PM +0200, Zdenek Kabelac wrote:
>>  lib/metadata/replicator.c        |  339 ++++++++++++++
>>  lib/replicator/replicator.c      |  912 ++++++++++++++++++++++++++++++++++++++
> 
> Filenames need to be globally unique in this tree: one of those needs
> renaming.
> 
> Alasdair
> 

lib/metadata/replicator.c  ->  lib/metadata/replicator_manip.c ?

Zdenek


