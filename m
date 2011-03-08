From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 8 Mar 2011 13:21:52 +0000
Subject: [PATCH 1/2] Fix read byte from char[-1] position
In-Reply-To: <4e9cb7c98861937ffc9ce6ac53b3e58124a2eb6f.1299089143.git.zkabelac@redhat.com>
References: <cover.1299089143.git.zkabelac@redhat.com>
	<4e9cb7c98861937ffc9ce6ac53b3e58124a2eb6f.1299089143.git.zkabelac@redhat.com>
Message-ID: <20110308132152.GB10767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 02, 2011 at 07:09:07PM +0100, Zdenek Kabelac wrote:
> When the ->params is empty string - access is made on the byte
> before allocated buffer (catched by valgrind) - in case it would
> constains 0x20 - it would even overwrite this buffer.
> So fix by checking len > 0 before doing such access.
 
Ack.

Alasdair


