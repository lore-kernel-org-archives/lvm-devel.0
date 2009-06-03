From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 3 Jun 2009 21:59:43 +0100
Subject: [PATCH 6/9] Udev integration: add lvmsplit command for dmsetup
In-Reply-To: <4A1A8CC3.2000809@redhat.com>
References: <4A1A8CC3.2000809@redhat.com>
Message-ID: <20090603205943.GG4077@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, May 25, 2009 at 02:19:15PM +0200, Peter Rajnoha wrote:
> Adds lvmsplit command for dmsetup that can split-up given DM name into
> its VG/LV/LAYER constituents. No change in here, too...
 
Checked in as 'dmsetup splitname' with the subsystem ('LVM') as a second
argument, optional.

Alasdair


