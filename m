From: Milan Broz <mbroz@redhat.com>
Date: Wed, 20 Oct 2010 15:30:08 +0200
Subject: [PATCH] (DRAFT!) Fix a deadlock in CLVMD (possibly related to BZ 561226).
In-Reply-To: <87wrpd9fuf.fsf@twilight.int.mornfall.net.>
References: <874ocje7y1.fsf@twilight.int.mornfall.net.>	<4CBEC730.4020906@redhat.com>
	<87wrpd9fuf.fsf@twilight.int.mornfall.net.>
Message-ID: <4CBEEEE0.4090101@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/20/2010 03:03 PM, Petr Rockai wrote:
> I would be actually wary about that -- I suspect that going the other
> way around could introduce a (very slight) race condition. Not that it
> would ever happen in practice, but still. On the other hand, I didn't
> try too hard to think about it, so I might be wrong.

ok, ack, please commit it.
... and wait what happens with tests.

m.


