From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 16 Jul 2012 23:17:58 +0100
Subject: [RFC PATCH 0/3] optimize detection of MD devices
In-Reply-To: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
References: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
Message-ID: <20120716221758.GB2641@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jul 16, 2012 at 11:18:36PM +0200, dongsu.park at profitbricks.com wrote:
> This patchset optimizes the detection mechanism of MD devices, as well

Optimising the detection, good.

> as introduces a possibility to turn off detections of the legacy
> metadata versions.
 
Maybe, but I'd discourage people from turning it off more strongly, as it's a
small price to pay for peace of mind.

So, after review and a bit of tweaking, yes, I'm in favour.

However, the whole of this code is itself 'legacy' in that this detection is
moving into blkid under udev's control, so you should check if that code is
sufficiently efficient too.

Alasdair


