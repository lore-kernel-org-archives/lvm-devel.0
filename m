From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 5 Apr 2011 19:08:54 +0100
Subject: snapshot in shared disk environment
In-Reply-To: <20110405174556.GH4849@agk-dp.fab.redhat.com>
References: <4D9AED98.1080900@ce.jp.nec.com>
	<20110405174556.GH4849@agk-dp.fab.redhat.com>
Message-ID: <20110405180854.GI4849@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 05, 2011 at 06:45:56PM +0100, Alasdair G Kergon wrote:
> If we enforce a read only origin, we can support selective snapshot activation.
> The tools will need some changes though to do this.
 
So activate/deactivate origin would work exactly as now, ensuring all
snapshots are active.

Additionally, we would allow activation/deactivation of individual snapshots
while the origin is read-only.

Alasdair


