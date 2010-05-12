From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 12 May 2010 02:07:25 +0100
Subject: [PATCH] LVM2: Disallow cluster attr change if mirror or snapshot is active
In-Reply-To: <1273613812.31265.3.camel@hydrogen.msp.redhat.com>
References: <1273613812.31265.3.camel@hydrogen.msp.redhat.com>
Message-ID: <20100512010725.GA2377@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 11, 2010 at 04:36:52PM -0500, Jon Brassow wrote:
> The new function 'lv_is_mirror' 

Let's make that 'lv_is_mirrored' to match the MIRRORED attribute name.

Ack.

Alasdair


