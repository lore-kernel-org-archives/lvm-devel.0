From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 30 Nov 2010 11:51:03 +0000
Subject: [PATCH] Disable automatic MISSING_PV recovery when handles_missing_pvs is set (BZ 653643)
In-Reply-To: <87hbezjc9c.fsf@twilight.int.mornfall.net.>
References: <87d3ptm965.fsf@twilight.int.mornfall.net.>
	<20101129224015.GS29380@agk-dp.fab.redhat.com>
	<87hbezjc9c.fsf@twilight.int.mornfall.net.>
Message-ID: <20101130115102.GB19659@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Nov 30, 2010 at 12:12:47PM +0100, Peter Rockai wrote:
> Which WARNING message you mean? There is only one in each command:

There are two quoted:

  WARNING: Inconsistent metadata found for VG helter_skelter - updating to use
version 493
  WARNING: PV /dev/sdf1 not found in VG helter_skelter

Alasdair


