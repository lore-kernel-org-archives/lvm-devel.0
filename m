From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 31 Jan 2011 17:20:41 +0100
Subject: [PATCH 1/1] Fix udev synchronization for no-locking mode
In-Reply-To: <87bp2xnm2x.fsf@twilight.int.mornfall.net.>
References: <cover.1296484980.git.zkabelac@redhat.com>	<4782409942e1848995a1f1abd3f9eb83ffb43de0.1296484980.git.zkabelac@redhat.com>
	<87bp2xnm2x.fsf@twilight.int.mornfall.net.>
Message-ID: <4D46E159.2020609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/31/2011 04:12 PM +0100, Petr Rockai wrote:
> On a second thought: are we sure this is not going to break clvmd?
> Please double-check that. There was trouble with that recently, IIRC.

...seems it's working fine (no locking/file locking/cluster locking).
The nodes are always synced now.

>> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> Reviewed-by: Petr Rockai <prockai@redhat.com>
Tested-by: Peter Rajnoha <prajnoha@redhat.com>


