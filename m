From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 5 Apr 2011 18:45:56 +0100
Subject: snapshot in shared disk environment
In-Reply-To: <4D9AED98.1080900@ce.jp.nec.com>
References: <4D9AED98.1080900@ce.jp.nec.com>
Message-ID: <20110405174556.GH4849@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 05, 2011 at 07:23:20PM +0900, Jun'ichi Nomura wrote:
>   b) Origin and snapshots are activated/deactivated as a whole set.
>      We can't individually activate/deactivate different snapshots on
>      different nodes.
 
> Also the origin is read-only.

If we enforce a read only origin, we can support selective snapshot activation.
The tools will need some changes though to do this.

Alasdair


